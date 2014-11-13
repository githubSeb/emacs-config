#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include "msg_callback.h"


/* discard all remaining contents on this line, jump to the beginning of the
   next line */
static void __skip_the_rest(FILE *fp)
{
    char crlf[LINE_MAX];
    fgets(crlf, LINE_MAX, fp);
}

/* read len bytes from fp to buffer */
static void __read_n_bytes(FILE *fp, char *buffer, int len)
{
    while (len-- != 0) {
        *buffer++ = (char)fgetc(fp);
    }
}


/* Read the source file portion of the message to the source code buffer in
   specified session object.

   Sourcefile segment always starts with source_length: [#len#], followed by a
   newline character, then the actual source code. Length of the source code is
   indicated by [#len#] so we know how much bytes we should read from fp.
*/
static void completion_readSourcefile(completion_Session *session, FILE *fp)
{
    int source_length;
    fscanf(fp, "source_length:%d", &source_length);
    __skip_the_rest(fp);

    if (source_length >= session->buffer_capacity) /* we're running out of space */
    {
        /* expand the buffer two-fold of source size */
        session->buffer_capacity = source_length * 2;
        session->src_buffer =
            (char*)realloc(session->src_buffer, session->buffer_capacity);
    }

    /* read source code from fp to buffer */
    session->src_length = source_length;
    __read_n_bytes(fp, session->src_buffer, source_length);
}

void completion_prepareLookup(completion_Session *session, FILE *fp, int *row, int *column) {
    /* get where cursor is */
    fscanf(fp, "row:%d",    row);    __skip_the_rest(fp);
    fscanf(fp, "column:%d", column); __skip_the_rest(fp);

    /* get a copy of fresh source file */
    completion_readSourcefile(session, fp);

    /* reparse the source to retrieve diagnostic message */
    completion_reparseTranslationUnit(session);
}

int completion_doLookup(completion_Session *session, FILE *fp, CXCursor (*lookup)(CXCursor), int row, int column) {
    int dest_row, dest_column, dest_offset;
    CXCursor source_cursor, dest_cursor;
    CXSourceLocation source_location, dest_location;
    CXFile source_file, dest_file;
    CXString dest_filename;

    source_file = clang_getFile(session->cx_tu, session->src_filename);

    source_location = clang_getLocation(
        session->cx_tu, source_file, row, column);

    source_cursor = clang_getCursor(session->cx_tu, source_location);

    if (clang_isInvalid(source_cursor.kind)) {
        return 0;
    }

    dest_cursor = lookup(source_cursor);

    if (clang_isInvalid(dest_cursor.kind)) {
        return 0;
    }

    dest_location = clang_getCursorLocation(dest_cursor);

    clang_getExpansionLocation(
        dest_location, &dest_file, &dest_row, &dest_column, &dest_offset);

    dest_filename = clang_getFileName(dest_file);

    fprintf(stdout, "%s %d %d\n",
        clang_getCString(dest_filename), dest_row, dest_column);

    return 1;
}

/* Get location of declaration of entry at current point (returns filename, row, column)
   Message format:
        row:[#row#]
        column:[#column#]
        source_length:[#src_length#]
        <# SOURCE CODE #>
*/
void completion_doDeclaration(completion_Session *session, FILE *fp) {
    int row, column;
    completion_prepareLookup(session, fp, &row, &column);
    completion_doLookup(session, fp, &clang_getCursorReferenced, row, column);
    fprintf(stdout, "$"); fflush(stdout);    /* end of output */
}

/* Get location of definition of entry at current point (returns filename, row, column)
   Message format:
        row:[#row#]
        column:[#column#]
        source_length:[#src_length#]
        <# SOURCE CODE #>
*/
void completion_doDefinition(completion_Session *session, FILE *fp) {
    int row, column;
    completion_prepareLookup(session, fp, &row, &column);
    completion_doLookup(session, fp, &clang_getCursorDefinition, row, column);
    fprintf(stdout, "$"); fflush(stdout);    /* end of output */
}

/* Get location of definition of entry at current point.  If that fails,
   get location of the declaration instead.  (returns filename, row, column).
   Message format:
        row:[#row#]
        column:[#column#]
        source_length:[#src_length#]
        <# SOURCE CODE #>
*/
void completion_doSmartJump(completion_Session *session, FILE *fp) {
    int row, column;
    completion_prepareLookup(session, fp, &row, &column);
    if (! completion_doLookup(session, fp, &clang_getCursorDefinition, row, column))
        completion_doLookup(session, fp, &clang_getCursorReferenced, row, column);
    fprintf(stdout, "$"); fflush(stdout);    /* end of output */
}

/* Read completion request (where to complete at and current source code) from message
   header and calculate completion candidates.

   Message format:
       row: [#row_number#]
       column: [#column_number#]
       source_length: [#src_length#]
       <# SOURCE CODE #>
*/
void completion_doCompletion(completion_Session *session, FILE *fp)
{
    CXCodeCompleteResults *res;

    /* get where to complete at */
    int row, column;
    fscanf(fp, "row:%d",    &row);    __skip_the_rest(fp);
    fscanf(fp, "column:%d", &column); __skip_the_rest(fp);

    /* get a copy of fresh source file */
    completion_readSourcefile(session, fp);

    /* calculate and show code completions results */
    res = completion_codeCompleteAt(session, row, column);
    if (res != NULL)
    {
	    /* code completion completed successfully, so we sort and dump these
         * completion candidates back to client */
	    clang_sortCodeCompletionResults(res->Results, res->NumResults);
	    completion_printCodeCompletionResults(res, stdout);
        clang_disposeCodeCompleteResults(res);
    }

    fprintf(stdout, "$"); fflush(stdout);    /* we need to inform emacs that all
                                                candidates has already been sent */
}


/* Reparse the source code to refresh the translation unit */
void completion_doReparse(completion_Session *session, FILE *fp)
{
    (void) fp;     /* get rid of unused parameter warning */
    completion_reparseTranslationUnit(session);
}

/* Update source code in src_buffer */
void completion_doSourcefile(completion_Session *session, FILE *fp)
{
    (void) fp;     /* get rid of unused parameter warning  */
    completion_readSourcefile(session, fp);
}


/* dispose command line arguments of session */
static void completion_freeCmdlineArgs(completion_Session *session)
{
    /* free each command line arguments */
    int i_arg = 0;
    for ( ; i_arg < session->num_args; i_arg++) {
        free(session->cmdline_args[i_arg]);
    }

    /* and dispose the arg vector */
    free(session->cmdline_args);
}

/* Update command line arguments passing to clang translation unit. Format
   of the coming CMDLINEARGS message is as follows:

       num_args: [#n_args#]
       arg1 arg2 ... (there should be n_args items here)
*/
void completion_doCmdlineArgs(completion_Session *session, FILE *fp)
{
    int i_arg = 0;
    char arg[LINE_MAX];

    /* destroy command line args, and we will rebuild it later */
    completion_freeCmdlineArgs(session);

    /* get number of arguments */
    fscanf(fp, "num_args:%d", &(session->num_args)); __skip_the_rest(fp);
    session->cmdline_args = (char**)calloc(sizeof(char*), session->num_args);

    /* rebuild command line arguments vector according to the message */
    for ( ; i_arg < session->num_args; i_arg++)
    {
        /* fetch an argument from message */
        fscanf(fp, "%s", arg);

        /* and add it to cmdline_args */
        session->cmdline_args[i_arg] = (char*)calloc(sizeof(char), strlen(arg) + 1);
        strcpy(session->cmdline_args[i_arg], arg);
    }

    /* we have to rebuild our translation units to make these cmdline args changes
       take place */
    clang_disposeTranslationUnit(session->cx_tu);
    completion_parseTranslationUnit(session);
    completion_reparseTranslationUnit(session);  /* dump PCH for acceleration */
}

/* Handle syntax checking request, message format:
       source_length: [#src_length#]
       <# SOURCE CODE #>
*/
void completion_doSyntaxCheck(completion_Session *session, FILE *fp)
{
    unsigned int i_diag = 0, n_diag;
    CXDiagnostic diag;
    CXString     dmsg;

    /* get a copy of fresh source file */
    completion_readSourcefile(session, fp);

    /* reparse the source to retrieve diagnostic message */
    completion_reparseTranslationUnit(session);

    /* dump all diagnostic messages to fp */
    n_diag = clang_getNumDiagnostics(session->cx_tu);
    for ( ; i_diag < n_diag; i_diag++)
    {
        diag = clang_getDiagnostic(session->cx_tu, i_diag);
        dmsg = clang_formatDiagnostic(diag, clang_defaultDiagnosticDisplayOptions());
        fprintf(stdout, "%s\n", clang_getCString(dmsg));
        clang_disposeString(dmsg);
        clang_disposeDiagnostic(diag);
    }

    fprintf(stdout, "$"); fflush(stdout);    /* end of output */
}

/* When emacs buffer is killed, a SHUTDOWN message is sent automatically by a hook
   function to inform the completion server (this program) to terminate. */
void completion_doShutdown(completion_Session *session, FILE *fp)
{
    (void) fp;    /* this parameter is unused, the server will shutdown
                   * directly without sending any messages to its client */

    /* free clang parser infrastructures */
    clang_disposeTranslationUnit(session->cx_tu);
    clang_disposeIndex(session->cx_index);

    /* free session properties */
    completion_freeCmdlineArgs(session);
    free(session->src_buffer);

    exit(0);   /* terminate completion process */
}
