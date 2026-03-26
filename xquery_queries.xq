for $r in doc("recipes.xml")/recipes/recipe
return <recipe-summary id="{$r/@id}">
    <title>{$r/title/text()}</title>
    <author>{$r/author/text()}</author>
    <rating>{$r/rating/text()}</rating>
</recipe-summary>

(: next query :)

for $r in doc("recipes.xml")/recipes/recipe
where $r/macros/calories < 300 or xs:decimal($r/rating) >= 4.8
order by xs:integer($r/macros/calories)
return <low-cal recipe="{$r/@id}">
    <title>{$r/title/text()}</title>
    <calories>{$r/macros/calories/text()}</calories>
    <rating>{$r/rating/text()}</rating>
</low-cal>

(: next query :)

for $cat in distinct-values(doc("recipes.xml")/recipes/recipe/@category)
let $items := doc("recipes.xml")/recipes/recipe[@category = $cat]
return <category name="{$cat}" count="{count($items)}">
    {
        for $r in $items
        return <recipe>{$r/title/text()}</recipe>
    }
</category>

(: next query :)

for $r in doc("recipes.xml")/recipes/recipe
return <recipe title="{$r/title/text()}" author="{$r/author/text()}">
    {
        for $ref in $r/ingredient-refs/ingredient-ref
        let $ing := doc("ingredients.xml")/ingredients/ingredient[@id = $ref/@ref]
        return <ingredient>{$ing/name/text()} ({$ing/amount/text()} {$ing/unit/text()})</ingredient>
    }
</recipe>

(: next query :)

let $recipes := doc("recipes.xml")/recipes/recipe
return <averages>
    <avg-calories>{round(avg($recipes/macros/calories))}</avg-calories>
    <avg-rating>{round-half-to-even(avg($recipes/rating), 2)}</avg-rating>
</averages>

(: next query :)

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

(: next query :)

for $cat in distinct-values(doc("ingredients.xml")/ingredients/ingredient/@category)
let $items := doc("ingredients.xml")/ingredients/ingredient[@category = $cat]
order by count($items) descending
return <category name="{$cat}" count="{count($items)}">
    {
        for $i in $items return <item>{$i/name/text()}</item>
    }
</category>

(: next query :)

for $r in doc("recipes.xml")/recipes/recipe
let $total := xs:integer($r/times/prep) + xs:integer($r/times/cook)
where $r/@category = "dinner" and $total > 30
order by $total descending
return <long-recipe>
    <title>{$r/title/text()}</title>
    <total-time unit="minutes">{$total}</total-time>
</long-recipe>

(: next query :)

for $diff in distinct-values(doc("recipes.xml")/recipes/recipe/@difficulty)
let $group := doc("recipes.xml")/recipes/recipe[@difficulty = $diff]
return <difficulty level="{$diff}">
    <count>{count($group)}</count>
    <avg-calories>{round(avg($group/macros/calories))}</avg-calories>
    <avg-protein>{round(avg($group/macros/protein))}</avg-protein>
    <avg-rating>{round-half-to-even(avg($group/rating), 2)}</avg-rating>
</difficulty>

(: next query :)

for $r in doc("recipes.xml")/recipes/recipe
where exists($r/tags/tag[. = "high-protein"])
    and contains(lower-case($r/title), "protein")
order by xs:decimal($r/rating) descending
return <tagged-recipe>
    <title>{$r/title/text()}</title>
    <author>{$r/author/text()}</author>
    <rating>{$r/rating/text()}</rating>
</tagged-recipe>