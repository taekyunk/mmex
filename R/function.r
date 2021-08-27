
#' Send query to mmex database and get the result
#'
#' @param sql_query  SQL query
#' @param db_path filepath to
#'
#' @return tibble from SQL query
query_db <- function(sql_query, db_path){
    on.exit(RSQLite::dbDisconnect(con))

    con <- RSQLite::dbConnect(RSQLite::SQLite(), db_path)
    df <- RSQLite::dbGetQuery(con, sql_query) %>%
        tibble::as_tibble() %>%
        janitor::clean_names()
    df
}


#' List all tables in mmex db.
#'
#' @param db_path
#'
#' @return character vector
#' @export
#'
#' @examples
#' test_db <- system.file("extdata", "mmex_test_database_2014-01-26.mmb", package = "mmex")
#' list_mmex_table(test_db)
list_mmex_table <- function(db_path){
    on.exit(RSQLite::dbDisconnect(con))

    con <- RSQLite::dbConnect(RSQLite::SQLite(), db_path)
    RSQLite::dbListTables(con)
}


#' Get a specific table from MMEX db using `query_db()`
#'
#' To find the list of tables, use `list_mmex_table(db_path)`
#'
#' @param tbl_name table within mmex db
#' @param db_path path to mmex db file
#'
#' @export
#'
#' @return tibble
#' @examples
#' test_db <- system.file("extdata", "mmex_test_database_2014-01-26.mmb", package = "mmex")
#' df_account <- read_mmex_table('accountlist_v1', test_db)
read_mmex_table <- function(tbl_name, db_path){
    if(!file.exists(db_path)){
        msg <- stringr::str_glue("Specified database does not exist.:\n {db_path}")
        stop(msg)
    }
    stringr::str_glue("select * from {tbl_name}") %>% query_db(db_path)
}


#' Read selected tables from MMEX database and combine it as a tibble.
#'
#' Note that this does not join all tables in the db.
#' It only joins
#' - checkingaccount
#' - accountlist
#' - category
#' - subcategory
#' - payee
#'
#' @param db_loc path to MMEX database
#'
#' @return tibble
#' @export
#' @examples
#' test_db <- system.file("extdata", "mmex_test_database_2014-01-26.mmb", package = "mmex")
#' df <- read_mmex_db(test_db)
read_mmex_db <- function(db_loc){
    if(!file.exists(db_loc)){
        msg <- stringr::str_glue("Specified database does not exist.:\n {db_loc}")
        stop(msg)
    }

    # read data
    df_tran <- read_mmex_table("checkingaccount_v1", db_loc)
    df_account <- read_mmex_table("accountlist_v1", db_loc)
    df_cat <- read_mmex_table("category_v1", db_loc)
    df_subcat <- read_mmex_table("subcategory_v1", db_loc)
    df_payee <- read_mmex_table("payee_v1", db_loc)

    df_account1 <-
        df_account %>%
        dplyr::select(accountid, accountname, accounttype, initialbal)

    df_account_name <-
        df_account1 %>%
        dplyr::select(accountid, accountname) %>%
        dplyr::rename(toaccountid = accountid) %>%
        dplyr::rename(toaccountname = accountname)

    # combine
    df <-
        df_tran %>%
        dplyr::mutate(transdate = lubridate::ymd(transdate)) %>%
        dplyr::left_join(df_account1, by = "accountid") %>%
        dplyr::left_join(df_account_name, by = 'toaccountid') %>%
        dplyr::left_join(df_payee %>% dplyr::select(payeeid, payeename), by = "payeeid") %>%
        dplyr::left_join(df_cat, by = "categid") %>%
        dplyr::left_join(df_subcat, by = c("categid", "subcategid")) %>%
        dplyr::mutate(cat_name = stringr::str_glue("{categname}:{dplyr::coalesce(subcategname)}") %>% as.character()) %>%
        # need to change signs for "Deposit"
        dplyr::mutate(transamount = ifelse(transcode == "Deposit", transamount, -transamount))
    df
}

