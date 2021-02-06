// TRANSFORM REVIEW EDGES INTO NEW NODES
MATCH (s:Scientific)-[old_r:reviews]->(a:Article)
DELETE old_r
WITH s, a
CREATE (r:Review {decision:'accepted'})
WITH s, r, a
CREATE (s)-[:makes_review]->(r)-[:review_of]->(a)
