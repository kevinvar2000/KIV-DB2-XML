---

## Project Domain: Fitness Cookbook

The **Fitness Cookbook** is a health-focused culinary database for meal planning and nutritional tracking. It contains fitness-oriented recipes and detailed ingredient metadata. The core is a **Many-to-Many (M:N) relationship** between recipes and ingredients: each recipe references multiple ingredients (via `ingredient_refs`), and each ingredient can be used in many recipes. This enables flexible querying by nutrition, tags, and ingredient availability.

---

## Attribute Classification

### RECIPES Collection
| Attribute           | Type                | Description                                   |
|---------------------|---------------------|-----------------------------------------------|
| _id                 | Text (ObjectId/str) | Unique recipe identifier (e.g., `rec_001`)    |
| title               | Text                | Recipe name                                   |
| difficulty          | Text                | Difficulty level (easy, medium, hard)         |
| category            | Text                | Meal type (breakfast, lunch, dinner, snack)   |
| description         | Text                | Recipe description                            |
| times.prep.value    | Number              | Preparation time (minutes)                    |
| times.cook.value    | Number              | Cooking time (minutes)                        |
| macros.calories     | Number              | Calories per serving                          |
| macros.protein      | Number              | Protein (g)                                   |
| macros.carbs        | Number              | Carbohydrates (g)                             |
| macros.fat          | Number              | Fat (g)                                       |
| ingredient_refs     | Array of Text       | List of ingredient IDs used                   |
| instructions        | Array of Objects    | Step-by-step instructions                     |
| tags                | Array of Text       | Tags (e.g., high-protein, vegetarian)         |
| created_at          | Date                | Creation date                                 |

### INGREDIENTS Collection
| Attribute   | Type   | Description                                 |
|-------------|--------|---------------------------------------------|
| ing_id      | Text   | Unique ingredient identifier (e.g., ing_1)  |
| name        | Text   | Ingredient name                             |
| category    | Text   | Ingredient type (base, dairy, protein, veg) |
| amount      | Number | Default quantity                            |
| unit        | Text   | Measurement unit (g, ml, unit, etc.)        |

---

## Sample Records

### Sample Recipe Document
```json
{
  "_id": "rec_001",
  "title": "Protein-Packed Blueberry Pancakes",
  "difficulty": "medium",
  "category": "breakfast",
  "description": "A low-carb, high-protein start to your day using Greek yogurt and oats.",
  "times": { "prep": { "value": 10, "unit": "minutes" }, "cook": { "value": 15, "unit": "minutes" } },
  "macros": { "calories": 350, "protein": 32, "carbs": 25, "fat": 8 },
  "ingredient_refs": ["ing_1", "ing_2", "ing_3"],
  "instructions": [
    { "step": 1, "text": "Blend the oats into a fine flour using a blender.", "tools": ["blender"] },
    { "step": 2, "text": "Whisk in egg whites and yogurt until smooth.", "tools": [] },
    { "step": 3, "text": "Cook on a non-stick pan over medium heat until bubbles form.", "tools": ["pan"] }
  ],
  "tags": ["high-protein", "vegetarian", "sugar-free"],
  "created_at": { "$date": "2026-03-07T00:00:00Z" }
}
```

### Sample Ingredient Document
```json
{
  "ing_id": "ing_1",
  "name": "Egg Whites",
  "category": "base",
  "amount": 150,
  "unit": "ml"
}
```

---

## ER Diagram

```
┌─────────────────────────────────────────────┐
│            RECIPES (Collection)             │
├─────────────────────────────────────────────┤
│ _id                                        │
│ title                                      │
│ ...                                        │
│ ingredient_refs (Array of ing_id)           │
└─────────────────────────────────────────────┘
                  │
                  │  M:N (ingredient_refs)
                  ▼
┌─────────────────────────────────────────────┐
│          INGREDIENTS (Collection)           │
├─────────────────────────────────────────────┤
│ ing_id                                      │
│ name                                        │
│ ...                                         │
└─────────────────────────────────────────────┘
```

---

## MongoDB Query Examples

See `queries/mongodb_queries.txt` for a full set of example queries.

### Example Queries

**1. Find all high-protein vegetarian recipes:**
```js
db.recipes.find({ $and: [ { "macros.protein": { $gt: 30 } }, { tags: "vegetarian" } ] })
```

**2. Recipes using an ingredient with "Egg" in its name:**
```js
db.recipes.aggregate([
  { $lookup: {
      from: "ingredients",
      localField: "ingredient_refs",
      foreignField: "ing_id",
      as: "ingredient_docs"
  }},
  { $match: { "ingredient_docs.name": { $regex: "Egg", $options: "i" } } },
  { $project: { title: 1, "ingredient_docs.name": 1 } }
])
```

**3. Quick recipes (prep ≤ 10 min), sorted by calories:**
```js
db.recipes.find({ "times.prep.value": { $lte: 10 } }, { title: 1, "macros.calories": 1 }).sort({ "macros.calories": 1 })
```

**4. Ingredients in "dairy" or "protein" category, missing amount:**
```js
db.ingredients.find({ category: { $in: ["dairy", "protein"] }, amount: { $exists: false } })
```

**5. Count recipes by category:**
```js
db.recipes.aggregate([
  { $group: { _id: "$category", count: { $sum: 1 } } }
])
```

---

## Discussion Points

- **Document structure:** Each recipe and ingredient is a separate document. Recipes reference ingredients by ID, supporting M:N relationships.
- **Embedded vs referenced:** Only simple ingredient references are used (not embedded objects), which is efficient for lookups and avoids duplication.
- **JSON format limitations:** No support for joins natively (handled via $lookup in aggregation). No schema enforcement unless using MongoDB schema validation.
- **Query limitations:** Some queries (e.g., complex joins, deep aggregations) are less efficient than in relational DBs. Optional fields (e.g., macros, tags) can complicate queries if missing.
- **Optional fields:** The existence of optional fields (e.g., macros, tags, instructions) is handled using $exists in queries.
