package main
/*
    CREATE TABLE IF NOT EXISTS balance (
        user_id INTEGER UNIQUE PRIMARY KEY,
        amount INTEGER NOT NULL DEFAULT '0'
    );
*/

import (
    "log"
    "strconv"
    "database/sql"
    
    _ "github.com/lib/pq"
    "github.com/gin-gonic/gin"
)

const (
    DSN             = "host=localhost port=5432 user=test password=test dbname=test sslmode=disable"
    //SQL_BALANCE     = "SELECT amount FROM balance WHERE user_id = $1"
    //SQL_CHECK_USER  = "SELECT COUNT(*) FROM balance WHERE user_id = $1"
    //SQL_CHECK_USERS = "SELECT COUNT(*) FROM balance WHERE user_id IN($1, $2)"
    SQL_GET_USER    = "SELECT amount FROM balance WHERE user_id = $1"
    SQL_CREATE_USER = "INSERT INTO balance (user_id, amount) VALUES($1, $2)"
    SQL_DEPOSIT     = "UPDATE balance SET amount = amount + $2 WHERE user_id = $1"
    SQL_WITHDRAW    = "UPDATE balance SET amount = amount - $2 WHERE user_id = $1"
)

func main() {
    var err error;
    
    db, err := sql.Open("postgres", DSN)
    defer db.Close()
    checkErr(err)
    
    err = db.Ping()
    checkErr(err)
  
    router := gin.Default()
    
    router.Use(DBM(db))
    
    router.GET("/balance", handleRequestBalance)
    router.POST("/deposit", handleRequestDeposit)
    router.POST("/withdraw", handleRequestWithdraw)
    router.POST("/transfer", handleRequestTransfer)
    
    router.Run()
}

func DBM(db *sql.DB) gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Set("DBM", db)
        c.Next()
    }
}

func checkErr(err error) {
    if err != nil {
        log.Fatal(err)
    }
}

type JSONCreditDebit struct {
    User   uint64 `json:"user" binding:"required"`
    Amount uint64 `json:"amount" binding:"required"`
}

type JSONTransfer struct {
    UserFrom uint64 `json:"from" binding:"required"`
    UserTo   uint64 `json:"to" binding:"required"`
    Amount   uint64 `json:"amount" binding:"required"`
}

type User struct {
    Id, Amount uint64
}

func (user *User) Create(id uint64, amount uint64, tx *sql.Tx) {
    query, err := tx.Prepare(SQL_CREATE_USER)
    checkErr(err)
    defer query.Close()
    
    _, err = query.Exec(id, amount)
    
    checkErr(err)
}

func (user *User) Get(id uint64, tx *sql.Tx) User {
    query, err := tx.Prepare(SQL_GET_USER)
    defer query.Close()
    checkErr(err)
    
    var value string
    
    err = query.QueryRow(id).Scan(&value)
    
    if err != nil {
        if err == sql.ErrNoRows {
            return User{0, 0}
        } else {
            log.Fatal(err)
        }
    }
    
    amount, err := strconv.ParseUint(value, 10, 64)
    
    checkErr(err)
    
    return User{Id: id, Amount: amount}
}

func (user *User) Deposit(amount uint64, tx *sql.Tx) {
    query, err := tx.Prepare(SQL_DEPOSIT)
    checkErr(err)
    defer query.Close()
    
    _, err = query.Exec(user.Id, amount)
    
    checkErr(err)
}

func (user *User) Withdraw(amount uint64, tx *sql.Tx) {
    query, err := tx.Prepare(SQL_WITHDRAW)
    checkErr(err)
    defer query.Close()
    
    _, err = query.Exec(user.Id, amount)
    
    checkErr(err)
}

func handleRequestBalance(context *gin.Context) {
    user_id := context.Query("user")
    
    if user_id == "" {
        context.String(422, "User is empty!")
        return
    }
    
    id, err := strconv.ParseUint(user_id, 10, 64)
    
    if err != nil {
        context.String(422, "User is not valid!")
        return
    }
    
    var u User
    
    db := context.MustGet("DBM").(*sql.DB)
    tx, err := db.Begin()
    checkErr(err)
    defer tx.Rollback()
    
    user := u.Get(id, tx);
    
    if user.Id == 0 {
        context.String(422, "User is not valid!")
        return
    }
    
    tx.Commit()

    context.JSON(200, gin.H{
        "balance": user.Amount,
    })
}

func handleRequestDeposit(context *gin.Context) {
    var json JSONCreditDebit
    
    if context.BindJSON(&json) == nil {
        var u User
        
        db := context.MustGet("DBM").(*sql.DB)
        tx, err := db.Begin()
        checkErr(err)
        defer tx.Rollback()
        
        user := u.Get(json.User, tx);
        
        if user.Id > 0 {
            user.Deposit(json.Amount, tx)
        } else {
            u.Create(json.User, json.Amount, tx)
        }
        
        tx.Commit()
    } else {
        context.String(422, "JSON request is not valid!")
        return
    }
}

func handleRequestWithdraw(context *gin.Context) {
    var json JSONCreditDebit
    
    if context.BindJSON(&json) == nil {
        var u User
        
        db := context.MustGet("DBM").(*sql.DB)
        tx, err := db.Begin()
        checkErr(err)
        defer tx.Rollback()
        
        user := u.Get(json.User, tx);
        
        if user.Id > 0 {
            if user.Amount >= json.Amount {
                user.Withdraw(json.Amount, tx)
                
                tx.Commit()
            } else {
                context.String(422, "Insufficient funds!")
                return
            }
        } else {
            context.String(422, "User is not valid!")
            return
        }
    } else {
        context.String(422, "JSON request is not valid!")
        return
    }
}

func handleRequestTransfer(context *gin.Context) {
    var json JSONTransfer
    
    if context.BindJSON(&json) == nil {
        var u User
        
        db := context.MustGet("DBM").(*sql.DB)
        tx, err := db.Begin()
        checkErr(err)
        defer tx.Rollback()
        
        userFrom := u.Get(json.UserFrom, tx);
        userTo := u.Get(json.UserTo, tx);
        
        if userFrom.Id == 0 {
            context.String(422, "Source user is not valid!")
            return
        }
        
        if userTo.Id == 0 {
            context.String(422, "Destination user is not valid!")
            return
        }
        
        if userFrom.Amount >= json.Amount {
            userFrom.Withdraw(json.Amount, tx)
            userTo.Deposit(json.Amount, tx)
            
            tx.Commit()
        } else {
            context.String(422, "Insufficient funds!")
            return
        }
    } else {
        context.String(422, "JSON request is not valid!")
        return
    }
}
