---------------------------- Method: #find (ActiveRecord::FinderMethods)
 (Defined in: activerecord/lib/active_record/relation/finder_methods.rb)

    findermethods.find(*args) 
------------------------------------------------------------------------

    Find operates with four different retrieval approaches: 
    
    * Find by id - This can either be a specific id (1), a list of ids
    (1, 5, 6), or an array of ids ([5, 6, 10]).
      If no record can be found for all of the listed ids, then
    RecordNotFound will be raised.
    * Find first - This will return the first record matched by the
    options used. These options can either be specific
      conditions or merely an order. If no record can be matched, +nil+
    is returned. Use
      <tt>Model.find(:first, *args)</tt> or its shortcut
    <tt>Model.first(*args)</tt>.
    * Find last - This will return the last record matched by the
    options used. These options can either be specific
      conditions or merely an order. If no record can be matched, +nil+
    is returned. Use
      <tt>Model.find(:last, *args)</tt> or its shortcut
    <tt>Model.last(*args)</tt>.
    * Find all - This will return all the records matched by the options
    used.
      If no records are found, an empty array is returned. Use
      <tt>Model.find(:all, *args)</tt> or its shortcut
    <tt>Model.all(*args)</tt>.
    
    
    All approaches accept an options hash as their last parameter. 
    
    ==== Options
    
    
    * <tt>:conditions</tt> - An SQL fragment like "administrator = 1",
    <tt>["user_name = ?", username]</tt>,
      or <tt>["user_name = :user_name", { :user_name => user_name
    }]</tt>. See conditions in the intro.
    * <tt>:order</tt> - An SQL fragment like "created_at DESC, name". *
    <tt>:group</tt> - An attribute name by which the result should be
    grouped. Uses the <tt>GROUP BY</tt> SQL-clause. * <tt>:having</tt> -
    Combined with +:group+ this can be used to filter the records that a
      <tt>GROUP BY</tt> returns. Uses the <tt>HAVING</tt> SQL-clause.
    * <tt>:limit</tt> - An integer determining the limit on the number
    of rows that should be returned. * <tt>:offset</tt> - An integer
    determining the offset from where the rows should be fetched. So at
    5,
      it would skip rows 0 through 4.
    * <tt>:joins</tt> - Either an SQL fragment for additional joins like
    "LEFT JOIN comments ON comments.post_id = id" (rarely needed),
      named associations in the same form used for the <tt>:include</tt>
    option, which will perform an
      <tt>INNER JOIN</tt> on the associated table(s),
      or an array containing a mixture of both strings and named
    associations.
      If the value is a string, then the records will be returned
    read-only since they will
      have attributes that do not correspond to the table's columns.
      Pass <tt>:readonly => false</tt> to override.
    * <tt>:include</tt> - Names associations that should be loaded
    alongside. The symbols named refer
      to already defined associations. See eager loading under
    Associations.
    * <tt>:select</tt> - By default, this is "*" as in "SELECT * FROM",
    but can be changed if you,
      for example, want to do a join but not include the joined columns.
    Takes a string with the SELECT SQL fragment (e.g. "id, name").
    * <tt>:from</tt> - By default, this is the table name of the class,
    but can be changed
      to an alternate table name (or even the name of a database view).
    * <tt>:readonly</tt> - Mark the returned records read-only so they
    cannot be saved or updated. * <tt>:lock</tt> - An SQL fragment like
    "FOR UPDATE" or "LOCK IN SHARE MODE".
      <tt>:lock => true</tt> gives connection's default exclusive lock,
    usually "FOR UPDATE".
    
    
    ==== Examples
    
    
      # find by id
      Person.find(1)       # returns the object for ID = 1
      Person.find(1, 2, 6) # returns an array for objects with IDs in
    (1, 2, 6)
      Person.find([7, 17]) # returns an array for objects with IDs in
    (7, 17)
      Person.find([1])     # returns an array for the object with ID = 1
      Person.where("administrator = 1").order("created_on DESC").find(1)
    
    
    Note that returned records may not be in the same order as the ids
    you provide since database rows are unordered. Give an explicit
    <tt>:order</tt> to ensure the results are sorted. 
    
    ==== Examples
    
    
      # find first
      Person.first # returns the first object fetched by SELECT * FROM
    people
      Person.where(["user_name = ?", user_name]).first
      Person.where(["user_name = :u", { :u => user_name }]).first
      Person.order("created_on DESC").offset(5).first
    
    
      # find last
      Person.last # returns the last object fetched by SELECT * FROM
    people
      Person.where(["user_name = ?", user_name]).last
      Person.order("created_on DESC").offset(5).last
    
    
      # find all
      Person.all # returns an array of objects for all the rows fetched
    by SELECT * FROM people
      Person.where(["category IN (?)", categories]).limit(50).all
      Person.where({ :friends => ["Bob", "Steve", "Fred"] }).all
      Person.offset(10).limit(10).all
      Person.includes([:account, :friends]).all
      Person.group("category").all
    
    
    Example for find with a lock: Imagine two concurrent transactions:
    each will read <tt>person.visits == 2</tt>, add 1 to it, and save,
    resulting in two saves of <tt>person.visits = 3</tt>.  By locking
    the row, the second transaction has to wait until the first is
    finished; we get the expected <tt>person.visits == 4</tt>. 
    
      Person.transaction do
        person = Person.lock(true).find(1)
        person.visits += 1
        person.save!
      end



