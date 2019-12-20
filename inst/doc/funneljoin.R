## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>", 
  message = FALSE
)

## -----------------------------------------------------------------------------
library(dplyr)
library(funneljoin)

## -----------------------------------------------------------------------------
landed

## -----------------------------------------------------------------------------
registered

## -----------------------------------------------------------------------------
landed %>%
  after_inner_join(registered, 
                   by_user = "user_id",
                   by_time = "timestamp",
                   type = "first-first")

## -----------------------------------------------------------------------------
landed %>%
  after_inner_join(registered, 
                   by_user = "user_id",
                   by_time = "timestamp",
                   type = "any-any", 
                   max_gap = as.difftime(4, units = "days"),
                   gap_col = TRUE)

## -----------------------------------------------------------------------------
experiment_starts <- tibble::tribble(
  ~user_id, ~timestamp, ~ alternative.name,
  1, "2018-07-01", "control",
  2, "2018-07-01", "treatment",
  3, "2018-07-02", "control",
  4, "2018-07-01", "control",
  4, "2018-07-04", "control",
  5, "2018-07-10", "treatment",
  5, "2018-07-12", "treatment",
  6, "2018-07-07", "treatment",
  6, "2018-07-08", "treatment"
) %>%
  mutate(timestamp = as.Date(timestamp))

experiment_registrations <- tibble::tribble(
  ~user_id, ~timestamp, 
  1, "2018-07-02", 
  3, "2018-07-02", 
  4, "2018-06-10", 
  4, "2018-07-02", 
  5, "2018-07-11", 
  6, "2018-07-10", 
  6, "2018-07-11", 
  7, "2018-07-07"
) %>%
  mutate(timestamp = as.Date(timestamp))

## -----------------------------------------------------------------------------
experiment_starts %>%
  after_left_join(experiment_registrations, 
                   by_user = "user_id",
                   by_time = "timestamp",
                   type = "first-firstafter")

## -----------------------------------------------------------------------------
experiment_starts %>%
  after_left_join(experiment_registrations, 
                   by_user = "user_id",
                   by_time = "timestamp",
                   type = "first-firstafter") %>% 
  group_by(alternative.name) %>%
  summarize_conversions(converted = timestamp.y)

## -----------------------------------------------------------------------------
for_conversion <- tibble::tribble(
  ~"experiment_group", ~"first_event", ~"last_event", ~"type", 
  "control", "2018-07-01", NA, "click",
  "control", "2018-07-02", NA, "click",
  "control", "2018-07-03", "2018-07-05", "click",
  "treatment", "2018-07-01", "2018-07-05", "click",
  "treatment", "2018-07-01", "2018-07-05", "click",
  "control", "2018-07-01", NA, "purchase",
  "control", "2018-07-02", NA, "purchase",
  "control", "2018-07-03", NA, "purchase",
  "treatment", "2018-07-01", NA, "purchase",
  "treatment", "2018-07-01", "2018-07-05", "purchase"
)

for_conversion %>%
  group_by(type, experiment_group) %>%
  summarize_conversions(converted = last_event)

## -----------------------------------------------------------------------------
tbl <- tibble::tribble(
  ~ experiment_group, ~nb_users, ~nb_conversions, ~type,
  "control", 500, 200, "purchase",
  "treatment", 500, 100, "purchase", 
  "control", 500, 360, "click",
  "treatment", 500, 375, "click"
)

tbl %>%
  group_by(type) %>%
  summarize_prop_tests(alternative_name = experiment_group)

