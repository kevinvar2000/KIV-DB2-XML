# XML Module

## Project Domain: Fitness Cookbook

This module stores the XML version of the Fitness Cookbook project.
The dataset is intentionally themed as celebrity healthy fitness recipes.

## Structure
- data: XML data documents
- queries: XPath and XQuery files

## Files
- data/recipes.xml
- data/ingredients.xml
- queries/xpath_queries.txt
- queries/xquery_queries.xq
- queries/queries.txt

## Running Queries
- XPath queries in queries/xpath_queries.txt are written against the document root nodes.
- XQuery queries in queries/xquery_queries.xq and queries/queries.txt use:
  - doc("../data/recipes.xml")
  - doc("../data/ingredients.xml")
  so they work when executed from the queries folder.
