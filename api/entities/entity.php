<?php
require_once __DIR__ . '/apientity.php';

class Entity extends APIEntity {
    /**
     * READ
     */
    public static function read($id) {
        $query = '
            SELECT * FROM Entity WHERE entityid = ?
            ';

        $stmt = DB::get()->prepare($query);
        $stmt->execute([$id]);
        return static::fetch($stmt);
    }

    public static function readAll() {
        $query = '
            SELECT * FROM Entity
            ';

        $stmt = DB::get()->prepare($query);
        $stmt->execute();
        return static::fetchAll($stmt);
    }
    
    /**
     * DELETE
     */
    public static function delete($id) {
        $query = '
            DELETE FROM Entity WHERE entityid = ?
            ';

        $stmt = DB::get()->prepare($query);
        $stmt->execute([$id]);
        return $stmt->rowCount();
    }
}
?>