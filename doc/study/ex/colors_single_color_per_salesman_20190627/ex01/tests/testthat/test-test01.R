context("test-test01")

test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("ex01_fun works", {
	ex01_fun()
  expect_equal(2 * 2, 4)
})

test_that("get_routes_verbal works", {
	init_routes_all = get_routes_verbal("report_20190526_00")
  expect_equal(2 * 2, 4)
})

