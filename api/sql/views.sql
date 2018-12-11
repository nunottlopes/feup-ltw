/**
 * User Views
 */
DROP VIEW IF EXISTS 'UserClean';
DROP VIEW IF EXISTS 'Author';
DROP VIEW IF EXISTS 'Creator';

CREATE VIEW UserClean AS
SELECT userid, username, email, admin
FROM User U
ORDER BY U.userid;

CREATE VIEW Author AS
SELECT userid AS authorid, username AS authorname, admin
FROM User U
ORDER BY U.userid;

CREATE VIEW Creator AS
SELECT userid AS creatorid, username AS creatorname, admin
FROM User U
ORDER BY U.userid;

/**
 * Entity Views
 */
DROP VIEW IF EXISTS 'ParentEntity';
DROP VIEW IF EXISTS 'ChildEntity';

CREATE VIEW ParentEntity AS
SELECT entityid AS parentid, authorid, createdat, updatedat, upvotes, downvotes
FROM Entity E
ORDER BY parentid ASC;

CREATE VIEW ChildEntity AS
SELECT entityid AS childid, authorid, createdat, updatedat, upvotes, downvotes
FROM Entity E
ORDER BY childid ASC;

/**
 * Story Views
 */
DROP VIEW IF EXISTS 'StoryEntity';
DROP VIEW IF EXISTS 'StoryAll';
DROP VIEW IF EXISTS 'StorySortTop';
DROP VIEW IF EXISTS 'StorySortBot';
DROP VIEW IF EXISTS 'StorySortHot';
DROP VIEW IF EXISTS 'StorySortAverage';
DROP VIEW IF EXISTS 'StorySortNew';
DROP VIEW IF EXISTS 'StorySortOld';

CREATE VIEW StoryEntity AS
SELECT *, 'story' type, E.upvotes - E.downvotes AS score
FROM Story S
NATURAL JOIN Entity E
ORDER BY entityid ASC;

CREATE VIEW StoryAll AS
SELECT SE.*, entityid as storyid, A.authorname, C.channelname
FROM StoryEntity SE
LEFT JOIN Author A ON SE.authorid = A.authorid
LEFT JOIN Channel C ON SE.channelid = C.channelid
ORDER BY entityid ASC;

CREATE VIEW StorySortTop AS
SELECT *
FROM StoryAll SA
ORDER BY score DESC;

CREATE VIEW StorySortBot AS
SELECT *
FROM StoryAll SA
ORDER BY score ASC;

CREATE VIEW StorySortHot AS
SELECT *, REDDITHOT(upvotes, downvotes, createdat) AS rating
FROM StoryAll SA
WHERE upvotes + downvotes > 0
ORDER BY rating DESC;

CREATE VIEW StorySortAverage AS
SELECT *, (upvotes + 1) / (upvotes + downvotes + 1) AS rating
FROM StoryAll SA
WHERE upvotes + downvotes > 0
ORDER BY rating DESC;

CREATE VIEW StorySortNew AS
SELECT *
FROM StoryAll SA
ORDER BY createdat DESC;

CREATE VIEW StorySortOld AS
SELECT *
FROM StoryAll SA
ORDER BY createdat ASC;

/**
 * Comment Views
 */
DROP VIEW IF EXISTS 'CommentEntity';
DROP VIEW IF EXISTS 'CommentAll';
DROP VIEW IF EXISTS 'CommentSortTop';
DROP VIEW IF EXISTS 'CommentSortBot';
DROP VIEW IF EXISTS 'CommentSortBest';
DROP VIEW IF EXISTS 'CommentSortControversial';
DROP VIEW IF EXISTS 'CommentSortAverage';
DROP VIEW IF EXISTS 'CommentSortNew';
DROP VIEW IF EXISTS 'CommentSortOld';

CREATE VIEW CommentEntity AS
SELECT *, 'comment' type, E.upvotes - E.downvotes AS score
FROM Comment C
NATURAL JOIN Entity E
ORDER BY entityid;

CREATE VIEW CommentAll AS
SELECT CE.*, A.authorname
FROM CommentEntity CE
LEFT JOIN Author A ON CE.authorid = A.authorid
ORDER BY entityid;

CREATE VIEW CommentSortTop AS
SELECT *
FROM CommentAll CA
ORDER BY score DESC;

CREATE VIEW CommentSortBot AS
SELECT *
FROM CommentAll CA
ORDER BY score ASC;

CREATE VIEW CommentSortBest AS
SELECT *, WILSONLOWERBOUND(upvotes, downvotes) AS rating
FROM CommentAll CA
WHERE upvotes + downvotes > 0
ORDER BY rating DESC;

CREATE VIEW CommentSortControversial AS
SELECT *, (upvotes + downvotes) / MAX(ABS(upvotes - downvotes), 1) AS rating
FROM CommentAll CA
WHERE upvotes + downvotes > 0
ORDER BY rating DESC;

CREATE VIEW CommentSortAverage AS
SELECT *, (upvotes + 1) / (upvotes + downvotes + 1) AS rating
FROM CommentAll CA
WHERE upvotes + downvotes > 0
ORDER BY rating DESC;

CREATE VIEW CommentSortNew AS
SELECT *
FROM CommentAll CA
ORDER BY createdat DESC;

CREATE VIEW CommentSortOld AS
SELECT *
FROM CommentAll CA
ORDER BY createdat ASC;

/**
 * Tree Views
 */
DROP VIEW IF EXISTS 'AscendantTree';
DROP VIEW IF EXISTS 'DescendantTree';
DROP VIEW IF EXISTS 'CommentTree';

CREATE VIEW EntityAscendantTree AS
SELECT T.descendantid, E.*, T.depth
FROM Tree T
JOIN Entity E ON T.ascendantid = E.entityid
ORDER BY T.ascendantid ASC;

CREATE VIEW EntityDescendantTree AS
SELECT T.ascendantid, E.*, T.depth
FROM Tree T
JOIN Entity E ON T.descendantid = E.entityid
ORDER BY T.descendantid ASC;

CREATE VIEW CommentAscendantTree AS
SELECT T.descendantid, CA.*, T.depth 
FROM Tree T
JOIN CommentAll CA ON T.ascendantid = CA.entityid
ORDER BY T.ascendantid ASC;

CREATE VIEW CommentDescendantTree AS
SELECT T.ascendantid, CA.*, T.depth
FROM Tree T
JOIN CommentAll CA ON T.descendantid = CA.entityid
ORDER BY T.descendantid ASC;

CREATE VIEW StoryTree AS
SELECT T.descendantid commentid, SA.*, T.depth
FROM Tree T
JOIN StoryAll SA ON T.ascendantid = SA.entityid
ORDER BY commentid ASC;