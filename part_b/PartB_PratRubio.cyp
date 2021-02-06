// H-INDEX
MATCH (s:Scientific)-[:writes]->(a1:Article)<-[:cites]-(a2:Article)
WITH s, a1, COUNT(a2) AS citations
ORDER BY s, citations DESC
WITH s, COLLECT(citations) AS list_citations
WITH s, [i IN RANGE(0, SIZE(list_citations) - 1) WHERE list_citations[i] >= i+1] AS valids
RETURN s AS author, SIZE(valids) AS hIndex;

// MOST-CITATED 
MATCH (a2:Article)-[:cites]->(a1:Article)-[:published_in]->(e:Edition)-[:part_of]->(c:Conference)
WITH c, a1, COUNT(a2) AS citations
ORDER BY c, citations DESC
RETURN c, COLLECT(a1)[..3]
ORDER BY c.name;

// COMMUNITY
MATCH (s:Scientific)-[:writes]->(a:Article)-[:published_in]->(e:Edition)-[:part_of]->(c:Conference)
WITH s, c, SIZE(COLLECT(DISTINCT e)) AS editions_participied
WHERE editions_participied >= 4
RETURN c, COLLECT(s);

// IMPACT FACTOR
MATCH (v:Volume)-[:belongs_to]->(j:Journal)
WITH j, COLLECT(DISTINCT(v.year)) as years
UNWIND years AS y
MATCH (a:Article)-[:published_in]->(v1:Volume)-[:belongs_to]->(j)
WHERE v1.year = y-1 OR v1.year=y-2
WITH y, j, COLLECT(a) AS publications
MATCH (citer:Article)-[:cites]->(a1:Article)
MATCH (citer)-[:published_in]->(n)
WHERE n.year = y AND a1 in publications
WITH y, j, count(citer) as cites, size(publications) as pubs
RETURN j, y, (cites * 1.0 / pubs) AS ImpactFactor
ORDER BY j, y;