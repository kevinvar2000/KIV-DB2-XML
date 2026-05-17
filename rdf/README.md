---

## Project Domain: Fitness Cookbook

The **Fitness Cookbook** is a specialized culinary database designed for health-conscious meal planning and nutritional tracking. It maintains a comprehensive collection of fitness-oriented recipes paired with detailed ingredient metadata. The core of this system rests on a **Many-to-Many ($M:N$) relationship** between recipes and ingredients: each recipe requires multiple ingredients, and each ingredient can be utilized across numerous recipes. This relational structure enables flexible querying of recipes by nutritional criteria, ingredient availability, and other attributes.

---

## Ontology and Data Model

The data is modeled as a Knowledge Graph using RDF. The structure is defined by an ontology (classes and properties) and populated with instance data (recipes and ingredients).

**Namespaces Used:**
- **`fc:`** `<http://fitnesscookbook.com/ontology#>` (Ontology: classes and properties)
- **`fcd:`** `<http://fitnesscookbook.com/data/>` (Data: recipe and ingredient instances)
- **`fcp:`** `<http://fitnesscookbook.com/person/>` (Data: author instances)
- **`rdf:`** `<http://www.w3.org/1999/02/22-rdf-syntax-ns#>`
- **`xsd:`** `<http://www.w3.org/2001/XMLSchema#>`

### `fc:Recipe` Class
| Predicate | Type | Description |
|-----------|------|-------------|
----
| `fc:title` | `xsd:string` | Recipe name |
| `fc:difficulty` | `xsd:string` | Difficulty level (easy, medium, hard) |
| `fc:category` | `xsd:string` | Meal type (breakfast, lunch, dinner, snack) |
| `fc:description` | `xsd:string` | Recipe description |
| `fc:prepTime` | `xsd:integer` | Preparation time (minutes) |
| `fc:cookTime` | `xsd:integer` | Cooking time (minutes) |
| `fc:calories` | `xsd:integer` | Calories per serving |
| `fc:protein` | `xsd:integer` | Protein (g) |
| `fc:usesIngredient` | `fc:Ingredient` | Link to an ingredient used in the recipe |
| `fc:author` | `fc:Person` | Link to the recipe's author |
| `fc:tag` | `xsd:string` | Tags (e.g., high-protein, vegetarian) |
| `fc:created` | `xsd:date` | Creation date |

### `fc:Ingredient` Class
| Predicate | Type | Description |
|-----------|------|-------------|
| `fc:name` | `xsd:string` | Ingredient name |
| `fc:category` | `xsd:string` | Ingredient type (base, dairy, protein, veg) |
| `fc:amount` | `xsd:integer` | Default quantity |
| `fc:unit` | `xsd:string` | Measurement unit (g, ml, etc.) |

---

## Sample Records

### Sample Recipe Record (Turtle)
```turtle
@prefix fc: <http://fitnesscookbook.com/ontology#> .
@prefix fcd: <http://fitnesscookbook.com/data/> .
@prefix fcp: <http://fitnesscookbook.com/person/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

fcd:rec_001 a fc:Recipe ;
    fc:title "Zendaya's Protein Blueberry Pancakes" ;
    fc:author fcp:Zendaya ;
    fc:rating "4.7"^^xsd:decimal ;
    fc:difficulty "medium" ;
    fc:category "breakfast" ;
    fc:created "2026-01-08"^^xsd:date ;
    fc:description "A light, camera-ready breakfast with balanced carbs and protein." ;
    fc:prepTime "10"^^xsd:integer ;
    fc:cookTime "15"^^xsd:integer ;
    fc:calories "350"^^xsd:integer ;
    fc:protein "32"^^xsd:integer ;
    fc:usesIngredient fcd:ing_1, fcd:ing_2, fcd:ing_3 ;
    fc:tag "high-protein", "vegetarian", "sugar-free" .
```

### Sample Ingredient Record (Turtle)
```turtle
@prefix fc: <http://fitnesscookbook.com/ontology#> .
@prefix fcd: <http://fitnesscookbook.com/data/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

fcd:ing_1 a fc:Ingredient ;
    fc:name "Egg Whites" ;
    fc:category "base" ;
    fc:amount "150"^^xsd:integer ;
    fc:unit "ml" .
```

---

## Graph Diagram

The data model forms a cyclic graph where entities have bidirectional links.

```
┌──────────────────┐       fc:author        ┌──────────────────┐
│    fc:Recipe     ├───────────────────────►│    fc:Person     │
│ (fcd:rec_001)    │◄───────────────────────┤  (fcp:Zendaya)   │
└──────────────────┘    fc:createdRecipe    └──────────────────┘
         │ ▲
         │ │ fc:usedIn
fc:usesIngredient │
         │ │
         ▼ │
┌──────────────────┐
│  fc:Ingredient   │
│   (fcd:ing_1)    │
└──────────────────┘
```

---

## SPARQL Query Examples

See `queries/sparql_queries.rq` for a full set of example queries.

**1. Find quick and light meals (< 400 calories):**
```sparql
PREFIX fc: <http://fitnesscookbook.com/ontology#>
SELECT ?title ?difficulty ?calories
WHERE {
  ?recipe a fc:Recipe ;
          fc:title ?title ;
          fc:difficulty ?difficulty ;
          fc:calories ?calories .
  FILTER ((?difficulty = "easy" || ?difficulty = "medium") && ?calories < 400)
}
```

**2. Find high-protein recipes that do not use vegetables:**
```sparql
PREFIX fc: <http://fitnesscookbook.com/ontology#>
SELECT ?title ?description
WHERE {
  ?recipe a fc:Recipe ;
          fc:title ?title .
  OPTIONAL { ?recipe fc:description ?description . }
  
  FILTER CONTAINS(lcase(?title), "protein")
  
  FILTER NOT EXISTS {
    ?recipe fc:usesIngredient/fc:category "veg" .
  }
}
```

**3. Aggregate nutritional information by category:**
```sparql
PREFIX fc: <http://fitnesscookbook.com/ontology#>
SELECT ?category (COUNT(?recipe) AS ?recipeCount) (ROUND(AVG(?calories)) AS ?avgCalories)
WHERE {
  ?recipe a fc:Recipe ;
          fc:category ?category ;
          fc:calories ?calories .
}
GROUP BY ?category
```

---

## Discussion Points

- **File Organization:** Best practice in RDF involves splitting the **Ontology** (T-Box: classes and properties) from the **Instance Data** (A-Box: the actual recipes and ingredients). This project could be split into `ontology.ttl`, `recipes.ttl`, and `ingredients.ttl`, which can be loaded into a single unified graph, simplifying maintenance.

- **RDF Format Limitations:** RDF is schema-less by default. Without a validation layer like SHACL or ShEx, there is no native enforcement of data types (e.g., ensuring calories are integers). Representing ordered lists, like recipe instructions, is also less straightforward in RDF (`rdf:List`) compared to JSON arrays.

- **Querying Limitations:** While SPARQL excels at graph pattern matching, it lacks built-in support for the complex mathematical or recursive analytics found in other languages like Cypher. Full-text search is also inefficient without specialized extensions like Apache Jena Text.

- **Handling Optional Data:** The existence of optional data requires careful querying. In SPARQL, if a triple pattern for an optional field (e.g., `?recipe fc:description ?desc`) does not match, the entire result row is excluded by default. To prevent this, optional patterns must be explicitly wrapped in an `OPTIONAL { ... }` block.

- **Bidirectional Relationships:** This dataset stores relationships in both directions (e.g., a recipe `fc:usesIngredient` and an ingredient is `fc:usedIn` a recipe). While this can make some queries more intuitive to write, it increases storage and introduces the risk of inconsistency if one direction is updated but the inverse is not. The alternative is to store a single direction and query the inverse relationship at runtime.

