# XML Documentation - XPath & XQuery Queries

This document contains 10 **XPath** and 10 **XQuery** queries operating on two XML files:

| File | Root Element | Description |
|------|-------------|-------------|
| `ingredients.xml` | `<ingredients>` | Standalone ingredient list (20 items) |
| `recipes.xml` | `<recipes>` | Recipes with ingredient references, author, and rating |

---

## XPath Queries

### 1. Select the first recipe title
```xpath
/recipes/recipe[1]/title
```
Returns the `<title>` of the first `<recipe>` node.

---

### 2. Find recipes with difficulty "easy" OR "medium"
```xpath
/recipes/recipe[@difficulty='easy' or @difficulty='medium']
```
Selects all `<recipe>` nodes where `difficulty` is `easy` or `medium`.

---

### 3. Get authors starting with "J" or containing "Kim"
```xpath
/recipes/recipe[starts-with(author, 'J') or contains(author, 'Kim')]/author
```
Returns author names that start with `J` or contain `Kim`.

---

### 4. Select highly rated recipes (rating >= 4.5)
```xpath
/recipes/recipe[number(rating) >= 4.5]
```
Filters recipes with rating 4.5 or higher.

---

### 5. Get ingredients in the "protein" category
```xpath
/ingredients/ingredient[@category='protein']/name
```
Returns names of ingredients categorized as protein (e.g., Chicken Breast, Tofu).

---

### 6. Get the prep time of a specific recipe by ID
```xpath
/recipes/recipe[@id='rec_004']/times/prep
```
Returns the prep time (15 minutes) for Quinoa Power Bowl.

---

### 7. Find recipes where vegetarian or vegan tag exists (exists())
```xpath
/recipes/recipe[exists(tags/tag[.='vegetarian' or .='vegan'])]
```
Selects recipes only when a `vegetarian` or `vegan` tag node exists.

---

### 8. Get the last ingredient measured in grams
```xpath
/ingredients/ingredient[unit='g'][last()]/name
```

Returns the name of the last ingredient whose unit is grams (g).
---

### 9. List the first 5 ingredients using position()
```xpath
/ingredients/ingredient[position() <= 5]/name
```
Returns names of ingredients in positions 1 through 5.

---

### 10. Find dinner recipes OR recipes with protein above 35g
```xpath
/recipes/recipe[@category='dinner' or macros/protein > 35]
```
Selects recipes that are in the dinner category or have protein above 35 g.

---

## XQuery Queries

### 1. List all recipe titles with author and rating
```xquery
for $r in doc("recipes.xml")/recipes/recipe
return <recipe-summary id="{$r/@id}">
    <title>{$r/title/text()}</title>
    <author>{$r/author/text()}</author>
    <rating>{$r/rating/text()}</rating>
</recipe-summary>
```
Produces a summary list including title, author, and rating.

---

### 2. Find recipes under 300 calories OR top-rated (>= 4.8), sorted by calories ascending
```xquery
for $r in doc("recipes.xml")/recipes/recipe
where $r/macros/calories < 300 or xs:decimal($r/rating) >= 4.8
order by xs:integer($r/macros/calories)
return <low-cal recipe="{$r/@id}">
    <title>{$r/title/text()}</title>
    <calories>{$r/macros/calories/text()}</calories>
    <rating>{$r/rating/text()}</rating>
</low-cal>
```
Returns light recipes or top-rated recipes ordered by calorie count.

---

### 3. Group recipes by category
```xquery
for $cat in distinct-values(doc("recipes.xml")/recipes/recipe/@category)
let $items := doc("recipes.xml")/recipes/recipe[@category = $cat]
return <category name="{$cat}" count="{count($items)}">
    {
        for $r in $items
        return <recipe>{$r/title/text()}</recipe>
    }
</category>
```
Groups recipes into breakfast, lunch, dinner, and snack categories.

---

### 4. Join recipes with ingredients (resolve ingredient references)
```xquery
for $r in doc("recipes.xml")/recipes/recipe
return <recipe title="{$r/title/text()}" author="{$r/author/text()}">
    {
        for $ref in $r/ingredient-refs/ingredient-ref
        let $ing := doc("ingredients.xml")/ingredients/ingredient[@id = $ref/@ref]
        return <ingredient>{$ing/name/text()} ({$ing/amount/text()} {$ing/unit/text()})</ingredient>
    }
</recipe>
```
Cross-references `recipes.xml` with `ingredients.xml` to show full ingredient details.

---

### 5. Calculate average calories and average rating
```xquery
let $recipes := doc("recipes.xml")/recipes/recipe
return <averages>
    <avg-calories>{round(avg($recipes/macros/calories))}</avg-calories>
    <avg-rating>{round-half-to-even(avg($recipes/rating), 2)}</avg-rating>
</averages>
```
Computes overall averages for calories and rating.

---

### 6. Find the top protein recipe using position [1]
```xquery
let $sorted :=
    for $r in doc("recipes.xml")/recipes/recipe
    order by xs:integer($r/macros/protein) descending
    return $r
let $r := $sorted[1]
return <highest-protein>
    <title>{$r/title/text()}</title>
    <author>{$r/author/text()}</author>
    <protein>{$r/macros/protein/text()}g</protein>
</highest-protein>
```
Returns the highest-protein recipe by selecting the first item of a descending sorted sequence.

---

### 7. Count ingredients per category
```xquery
for $cat in distinct-values(doc("ingredients.xml")/ingredients/ingredient/@category)
let $items := doc("ingredients.xml")/ingredients/ingredient[@category = $cat]
order by count($items) descending
return <category name="{$cat}" count="{count($items)}">
    {
        for $i in $items return <item>{$i/name/text()}</item>
    }
</category>
```
Lists each ingredient category with item count and names.

---

### 8. List dinner recipes with total time (prep + cook) over 30 minutes (AND)
```xquery
for $r in doc("recipes.xml")/recipes/recipe
let $total := xs:integer($r/times/prep) + xs:integer($r/times/cook)
where $r/@category = "dinner" and $total > 30
order by $total descending
return <long-recipe>
    <title>{$r/title/text()}</title>
    <total-time unit="minutes">{$total}</total-time>
</long-recipe>
```
Filters only dinner recipes requiring more than 30 minutes total.

---

### 9. Generate summary by difficulty (including average rating)
```xquery
for $diff in distinct-values(doc("recipes.xml")/recipes/recipe/@difficulty)
let $group := doc("recipes.xml")/recipes/recipe[@difficulty = $diff]
return <difficulty level="{$diff}">
    <count>{count($group)}</count>
    <avg-calories>{round(avg($group/macros/calories))}</avg-calories>
    <avg-protein>{round(avg($group/macros/protein))}</avg-protein>
    <avg-rating>{round-half-to-even(avg($group/rating), 2)}</avg-rating>
</difficulty>
```
Aggregates calories, protein, and rating for easy, medium, and hard recipes.

---

### 10. Find recipes where a high-protein tag exists and title contains "protein"
```xquery
for $r in doc("recipes.xml")/recipes/recipe
where exists($r/tags/tag[. = "high-protein"])
    and contains(lower-case($r/title), "protein")
order by xs:decimal($r/rating) descending
return <tagged-recipe>
    <title>{$r/title/text()}</title>
    <author>{$r/author/text()}</author>
    <rating>{$r/rating/text()}</rating>
</tagged-recipe>
```
Returns recipes that contain a `high-protein` tag and whose title contains `protein`.

---

## Discussion

### 1. File organization
A single file in this project has clear semantic meaning: `recipes.xml` stores recipe entities and `ingredients.xml` stores ingredient entities. This separation makes reuse and maintenance easier because ingredients can be referenced by multiple recipes. For processing, fewer larger files can reduce document-open overhead, while multiple smaller files improve modularity and team collaboration. For this domain, two medium files are a practical compromise.

### 2. Elements vs. attributes
Attributes are used for compact metadata and identifiers (e.g., `id`, `difficulty`, `category`, `created`, `updated`), while elements are used for richer or repeatable content (e.g., `title`, `description`, `tags`, `macros`). This choice affects querying: attribute filters are concise (`@category = "dinner"`), while element content is more flexible for text and aggregation (`avg($group/macros/calories)`).

### 3. XML format limitations
XML is verbose and can become large for datasets with many repeated records. It has no built-in referential integrity enforcement, so consistency between `ingredient-ref` and `ingredient/@id` must be validated by queries or external rules. Schema evolution can also be cumbersome when optional/new fields are introduced frequently.

### 4. Querying limitations
XQuery is strong for hierarchical extraction, joins, and aggregation, but some analytical tasks are harder compared to SQL/OLAP systems, especially complex window analytics, incremental updates at scale, and ad-hoc full-text relevance ranking unless extra modules/indexes are configured.

### 5. Optional data
Optional fields are manageable but require defensive querying (for example using `exists()` checks). Missing optional nodes can otherwise lead to empty outputs or incorrect assumptions in conditions and aggregations. In this project, optionality is acceptable as long as queries explicitly handle missing elements.
