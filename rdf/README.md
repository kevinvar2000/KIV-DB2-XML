# RDF Module - Fitness Cookbook

This module contains the RDF/Turtle representation of the Fitness Cookbook dataset, designed for Apache Jena Fuseki.

## Project Domain & Data Structure

The dataset utilizes Semantic Web technologies to model the recipes. 
The structure takes advantage of triples (`Subject -> Predicate -> Object`) to form a Knowledge Graph.

### Namespaces used:
1. **`fc:`** `<http://fitnesscookbook.com/ontology#>` - Used for classes and properties (Ontology).
2. **`fcd:`** `<http://fitnesscookbook.com/data/>` - Used for recipe and ingredient resources (Data).
3. **`fcp:`** `<http://fitnesscookbook.com/person/>` - Used specifically for Person/Author resources (Data schema 2).

### Cyclic Graph Requirement
The data model is deliberately built as a **cyclic graph**:
- A Person (e.g., `fcp:Zendaya`) created a Recipe (`fc:createdRecipe fcd:rec_001`).
- The Recipe (`fcd:rec_001`) simultaneously references the Person as its author (`fc:author fcp:Zendaya`).
This forms a bidirectional relationship loop in the graph. The same bidirectional cycle is applied to ingredients (`fc:usesIngredient` and `fc:usedIn`).

---

## SPARQL Queries Description

The `sparql_queries.rq` file contains 4 queries addressing real-world questions:

**Query 1: Quick & Light Meals (Logical AND, OR, Numeric Filter)**
*Question:* "What recipes are easy or medium to prepare and contain less than 400 calories?"
*Description:* Uses the `FILTER` clause with `||` (OR) to check the difficulty, combined with `&&` (AND) to ensure the `?calories` numeric value is `< 400`.

**Query 2: High-Protein without Veggies (Substring, OPTIONAL, NOT EXISTS)**
*Question:* "Show me recipes with 'Protein' in the title and their descriptions (if available), but exclude any that use vegetables."
*Description:* Uses `FILTER(CONTAINS(...))` to match substrings. `OPTIONAL` safely attempts to extract the description, returning empty if the recipe lacks one. `FILTER NOT EXISTS` traverses the graph to eliminate recipes using ingredients with the `veg` category.

**Query 3: Celebrity Ingredient Audit (VALUES n-tuples, Property Paths)**
*Question:* "For these specific recipes and their respective authors, what categories of ingredients are being used?"
*Description:* Uses the `VALUES` keyword to bind pairs (2-tuples) of explicit Recipe Titles and Author Names. A **Property Path** (`fc:usesIngredient/fc:category`) is utilized to elegantly jump from the recipe to the ingredient and immediately extract its category in a single step.

**Query 4: Nutritional Aggregation (GROUP BY, Aggregation Functions)**
*Question:* "What is the average calorie count and total number of recipes per meal category?"
*Description:* Groups recipes by `?category` using `GROUP BY`, and then applies standard SQL-like aggregation functions `COUNT(?recipe)` and `AVG(?calories)` to summarize the dataset.

---

## Discussion / Rozbor (Assignment Discussion Points)

### 1. Členění do souborů (File splitting)
*Bylo by možné model smysluplně rozčlenit do více souborů?*
Yes, absolutely. Best practice in RDF often involves splitting the **Ontology** (T-Box: classes like `fc:Recipe` and properties like `fc:usesIngredient`) from the **Instance Data** (A-Box: the actual recipes like `fcd:rec_001`). Furthermore, the dataset could be split into `recipes.ttl`, `ingredients.ttl`, and `authors.ttl`. Fuseki can load all these separate files into a single unified dataset graph seamlessly, which makes maintenance much easier.

### 2. Limitace datového formátu RDF (RDF Format Limitations)
*Limitace datového formátu RDF pro uložení dat z této domény.*
RDF is inherently schema-less at the graph level unless paired with validators like SHACL or ShEx. This means in our cookbook, there's nothing natively preventing someone from inserting a string `"high"` into a calorie count where an integer is expected. Additionally, representing ordered lists—such as step-by-step recipe instructions—is notoriously clunky in RDF (requiring `rdf:List`/blank nodes), whereas it is trivial in JSON arrays.

### 3. Limitace v dotazování (Query Limitations)
*Na jaké otázky není možné nebo je těžké odpovědět?*
While SPARQL is incredibly powerful for graph traversal, it lacks native support for complex mathematical calculations or recursive analytics compared to Graph-specific querying languages (like Cypher) or SQL window functions. Ad-hoc Full-Text search (e.g., "Find recipes matching 'pancake' with typos") is also highly inefficient with standard `CONTAINS` regex filters unless Apache Jena Text (Lucene index) is configured on top of the dataset.

### 4. Nepovinné údaje (Optional Data Problematic?)
*Je problematická existence nepovinných údajů?*
Yes, it can be a trap for beginners. In SQL or JSON, a missing attribute might just return `NULL`. In SPARQL graph pattern matching, if a triple pattern (like `?recipe fc:description ?desc`) is requested but doesn't exist, **the entire result row is dropped** from the output. Developers must proactively wrap fields they know are optional inside the `OPTIONAL { ... }` block to avoid inadvertently filtering out valid results.

### 5. Směr relací (Edge Direction)
*Způsob zapsání relace mezi uzly – uložit pouze hranu orientovanou jedním směrem, nebo uložit i inverzní hranu?*
In this dataset, I chose to materialize **both directions** (e.g., `fc:usesIngredient` and `fc:usedIn` + `fc:author` and `fc:createdRecipe`). 
- **Pros:** It allows queries to be written more naturally depending on the starting entity, and explicitly states the relationship.
- **Cons:** It increases storage footprint and risks data inconsistency (updating one edge but forgetting the other). 
Alternatively, we could store only one direction (e.g., `fc:usesIngredient`) and let SPARQL handle the inverse queries using the `^` operator (`?ingredient ^fc:usesIngredient ?recipe`). In massive datasets, computing the inverse at query time is standard practice to save space.
