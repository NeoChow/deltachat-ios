#include "dc_context.h"
#include "dc_token.h"


void dc_token_save(dc_context_t* context, dc_tokennamespc_t namespc, uint32_t foreign_id, const char* token)
{
	sqlite3_stmt* stmt = NULL;

	if (context==NULL || context->magic!=DC_CONTEXT_MAGIC || token==NULL) { // foreign_id may be 0
		goto cleanup;
	}

	stmt = dc_sqlite3_prepare(context->sql,
		"INSERT INTO tokens (namespc, foreign_id, token, timestamp) VALUES (?, ?, ?, ?);");
	sqlite3_bind_int  (stmt, 1, (int)namespc);
	sqlite3_bind_int  (stmt, 2, (int)foreign_id);
	sqlite3_bind_text (stmt, 3, token, -1, SQLITE_STATIC);
	sqlite3_bind_int64(stmt, 4, time(NULL));
	sqlite3_step(stmt);

cleanup:
	sqlite3_finalize(stmt);
}


char* dc_token_lookup(dc_context_t* context, dc_tokennamespc_t namespc, uint32_t foreign_id)
{
	char*         token = NULL;
	sqlite3_stmt* stmt = NULL;

	if (context==NULL || context->magic!=DC_CONTEXT_MAGIC) {
		goto cleanup;
	}

	stmt = dc_sqlite3_prepare(context->sql,
		"SELECT token FROM tokens WHERE namespc=? AND foreign_id=?;");
	sqlite3_bind_int (stmt, 1, (int)namespc);
	sqlite3_bind_int (stmt, 2, (int)foreign_id);
	sqlite3_step(stmt);

	token = dc_strdup_keep_null((char*)sqlite3_column_text(stmt, 0));

cleanup:
	sqlite3_finalize(stmt);
	return token;
}


int dc_token_exists(dc_context_t* context, dc_tokennamespc_t namespc, const char* token)
{
	int           exists = 0;
	sqlite3_stmt* stmt = NULL;

	if (context==NULL || context->magic!=DC_CONTEXT_MAGIC || token==NULL) {
		goto cleanup;
	}

	stmt = dc_sqlite3_prepare(context->sql,
		"SELECT id FROM tokens WHERE namespc=? AND token=?;");
	sqlite3_bind_int (stmt, 1, (int)namespc);
	sqlite3_bind_text(stmt, 2, token, -1, SQLITE_STATIC);

	exists = (sqlite3_step(stmt)!=0);

cleanup:
	sqlite3_finalize(stmt);
	return exists;
}
