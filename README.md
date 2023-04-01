
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mmex

<!-- badges: start -->
<!-- badges: end -->

The goal of mmex is to make it easy to read information from Money
Manager EX (MMEX) database. MMEX is an excellent open source personal
finance manager and you can find and download from
[here](https://www.moneymanagerex.org/)

For instance, MMEX has the following benefits

- It is freeware and open source
- It is available in multiple platform (e.g. PC and Android).
- The database (SQLite format) syncs across platform using Google Drive

This package is built for my personal use to create reports of my
personal finance. As a result, it does not support *all* features of
MMEX. For instance, I do not use investment accounts so this package
does not support it. Even though I have some investments, I just keep
track of initial investment amount as Bank accounts.

However, this package includes utility functions to

- list all tables
- get one table by name

So, you can pull tables of interest and join them properly by using the
table relationship described
[here](https://github.com/moneymanagerex/database)

## Note

- Only supports up to [version
  1.6.1](https://github.com/moneymanagerex/moneymanagerex/releases/tag/v1.6.1)
- After version 1.6.2, the category structure is more flexible and I
  don’t personally use them.

## Author

Taekyun (TK) Kim (<taekyunk@gmail.com>)

## Installation

You can install the github version of mmex with:

``` r
library(devtools)
install_github("taekyunk/mmex") 
```

## Example

Find tables in MMEX db

``` r
library(mmex)
test_db <- system.file("extdata", "mmex_test_database_2014-01-26.mmb", package = "mmex")
list_mmex_table(test_db)
#>  [1] "ACCOUNTLIST_V1"             "ASSETS_V1"                 
#>  [3] "BILLSDEPOSITS_V1"           "BUDGETSPLITTRANSACTIONS_V1"
#>  [5] "BUDGETTABLE_V1"             "BUDGETYEAR_V1"             
#>  [7] "CATEGORY_V1"                "CHECKINGACCOUNT_V1"        
#>  [9] "CURRENCYFORMATS_V1"         "INFOTABLE_V1"              
#> [11] "PAYEE_V1"                   "REPORT_V1"                 
#> [13] "SETTING_V1"                 "SPLITTRANSACTIONS_V1"      
#> [15] "STOCK_V1"                   "SUBCATEGORY_V1"
```

Read one table from MMEX db.

- To find the list of tables, use `list_mmex_table()`
- To find the relationship between tables, refer to this
  <https://github.com/moneymanagerex/database>

``` r
library(mmex)
test_db <- system.file("extdata", "mmex_test_database_2014-01-26.mmb", package = "mmex")
df_account <- read_mmex_table('accountlist_v1', test_db)
```

Read some selected tables as one data.frame/tibble. Note that this
function joins mostly useful for me, but not all tables.

``` r
library(mmex)
test_db <- system.file("extdata", "mmex_test_database_2014-01-26.mmb", package = "mmex")
df <- read_mmex_db(test_db)
df
#> # A tibble: 8,069 × 22
#>    transid accoun…¹ toacc…² payeeid trans…³ trans…⁴ status trans…⁵ notes categid
#>      <int>    <int>   <int>   <int> <chr>     <dbl> <chr>  <chr>   <chr>   <int>
#>  1       1        3       4      -1 Transf…  -10000 R      ""      "Ini…      16
#>  2       2        1      -1       5 Deposit    1200 R      ""      ""         13
#>  3       3        1      -1       5 Withdr…    -300 R      ""      ""         13
#>  4       4        1      -1       5 Deposit    1500 R      ""      ""         13
#>  5       5        1      -1       5 Withdr…    -375 R      ""      ""         13
#>  6       6        1      -1       5 Deposit    1200 R      ""      ""         13
#>  7       7        1      -1       5 Withdr…    -300 R      ""      ""         13
#>  8       8        1      -1       5 Deposit    1200 R      ""      ""         13
#>  9       9        1      -1       5 Withdr…    -300 R      ""      ""         13
#> 10      10        1      -1       6 Deposit    1600 R      ""      ""         13
#> # … with 8,059 more rows, 12 more variables: subcategid <int>,
#> #   transdate <date>, followupid <int>, totransamount <dbl>, accountname <chr>,
#> #   accounttype <chr>, initialbal <int>, toaccountname <chr>, payeename <chr>,
#> #   categname <chr>, subcategname <chr>, cat_name <chr>, and abbreviated
#> #   variable names ¹​accountid, ²​toaccountid, ³​transcode, ⁴​transamount,
#> #   ⁵​transactionnumber
```

Note that the test database is from this
[link](https://forum.moneymanagerex.org/viewtopic.php?f=7&t=5397)
