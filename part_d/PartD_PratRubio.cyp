// DEFINE RESEARCH COMMUNITIES
CREATE INDEX ON :Community(name);

CREATE (c:Community {name:'database'})
WITH c, ['data management', 'indexing', 'data modeling', 'big data', 'data processing', 'data storage', 'data querying'] AS community_keys
UNWIND community_keys as key
MERGE (k:Keyword {topic:key})
MERGE (c)-[:related_to]->(k);

// FIND RELATIONS TO COMMUNITY IN JOURNALS AND CONFERENCES
MATCH (c:Community)-[:related_to]->(k:Keyword)
WITH c, COLLECT(k) AS keywords
MATCH (a:Article)-[:published_in]->(v)-[:belongs_to|:part_of]->(j)
WHERE (v:Volume OR v:Edition) AND (j:Journal OR j:Conference)
WITH c, j, keywords, COLLECT(a) AS publications
UNWIND publications AS a
MATCH (a)-[:has]->(key:Keyword)
WHERE key IN keywords
WITH c, j, publications, COLLECT(a) AS using_keywords
WHERE (SIZE(using_keywords) * 100.0 / SIZE(publications)) >= 90.0
CREATE (j)-[:forms]->(c);

// FIND TOP 100 PAPERS
MATCH (a:Article)-[:published_in]->(x)-[:belongs_to|:part_of]->(y)-[:forms]->(c:Community)
WHERE (x:Edition OR x:Volume) AND (y:Conference OR y:Journal)
WITH c, COLLECT(a) AS articles_from_community
CALL algo.pageRank.stream('articles_from_community', 'cites', {iterations:20, dampingFactor:0.85})
YIELD nodeId, score
MATCH (art:Article)
WHERE id(art)=nodeId
WITH c, art, score
ORDER BY score DESC
WITH c, art LIMIT 100
CREATE (art)-[:is_top_from]->(c);

// FIND GURUS
MATCH (s:Scientific)-[:writes]->(a:Article)-[:is_top_from]->(c:Community)
WITH s, c, COLLECT(a) AS articles
WHERE SIZE(articles)>=2 
MERGE (s)-[:is_guru_of]->(c);

// FIND REVIEWERS
MATCH (s:Scientific)-[:writes]->(a:Article)-[:is_top_from]->(c:Community)
MERGE (s)-[:is_reviewer_of]->(c);