;; Title: Bitcoin Options - Decentralized Bitcoin Options Trading Protocol
;; 
;; Summary:
;; A sophisticated decentralized options trading protocol built on Stacks L2,
;; enabling secure and efficient Bitcoin-settled options trading with automated
;; execution and robust price oracle integration.
;;
;; Description:
;; Bitcoin Options revolutionizes Bitcoin options trading by providing a trustless,
;; fully-collateralized platform that leverages Stacks' Bitcoin L2 capabilities.
;; The protocol features:
;;  - Automated option creation and settlement
;;  - Real-time BTC price oracle integration
;;  - Dynamic collateral management
;;  - Configurable platform parameters
;;  - Comprehensive security controls


;; Constants and Error Codes

;; Administrative
(define-constant CONTRACT_OWNER tx-sender)

;; Protocol Parameters
(define-constant MAX_FEE_BASIS_POINTS u10000)    ;; Maximum fee: 100%
(define-constant MAX_COLLATERAL_RATIO u1000)     ;; Maximum collateral: 1000%
(define-constant MIN_DEPOSIT_AMOUNT u1000)       ;; Minimum deposit allowed
(define-constant MAX_DEPOSIT_AMOUNT u100000000000) ;; Maximum deposit: 1000 BTC
(define-constant MIN_VALIDITY_WINDOW u10)        ;; Minimum price validity: ~10 min
(define-constant MAX_VALIDITY_WINDOW u1440)      ;; Maximum validity: ~24 hours

;; Error Definitions
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_OPTION_NOT_FOUND (err u103))
(define-constant ERR_OPTION_EXPIRED (err u104))
(define-constant ERR_INVALID_STRIKE_PRICE (err u105))
(define-constant ERR_INVALID_EXPIRY (err u106))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u107))
(define-constant ERR_OPTION_NOT_EXERCISABLE (err u108))
(define-constant ERR_STALE_PRICE (err u109))
(define-constant ERR_INVALID_PRICE (err u110))
(define-constant ERR_OPTION_NOT_EXPIRED (err u111))
(define-constant ERR_INVALID_PARAMETER (err u112))

;; Data Variables

;; Protocol Configuration
(define-data-var min-collateral-ratio uint u150)  ;; 150% collateral ratio
(define-data-var platform-fee uint u10)           ;; 0.1% fee (basis points)
(define-data-var next-option-id uint u0)

;; Oracle Configuration
(define-data-var oracle-address principal CONTRACT_OWNER)
(define-data-var btc-price uint u0)
(define-data-var price-last-updated uint u0)
(define-data-var price-validity-window uint u150)  ;; ~25 minutes in blocks

;; Data Maps

;; Options Registry
(define-map options
    uint  ;; option-id
    {
        creator: principal,
        holder: principal,
        option-type: (string-ascii 4),  ;; "CALL" or "PUT"
        strike-price: uint,
        expiry: uint,
        amount: uint,
        collateral: uint,
        status: (string-ascii 10)  ;; "ACTIVE", "EXERCISED", "EXPIRED"
    }
)

;; User Balance Tracking
(define-map user-balances
    principal
    {
        sbtc-balance: uint,
        locked-collateral: uint
    }
)

;; Oracle Functions

(define-public (update-btc-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender (var-get oracle-address)) ERR_NOT_AUTHORIZED)
        (asserts! (> new-price u0) ERR_INVALID_PRICE)
        (var-set btc-price new-price)
        (var-set price-last-updated block-height)
        (ok true))
)

(define-read-only (get-current-btc-price)
    (let (
        (price (var-get btc-price))
        (last-updated (var-get price-last-updated))
        (validity-window (var-get price-validity-window))
    )
    (asserts! (> price u0) ERR_INVALID_PRICE)
    (asserts! (< (- block-height last-updated) validity-window) ERR_STALE_PRICE)
    (ok price))
)

(define-public (set-oracle-address (new-oracle principal))
    (begin
        (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
        (asserts! (not (is-eq new-oracle 'SP000000000000000000002Q6VF78)) ERR_INVALID_PARAMETER)
        (var-set oracle-address new-oracle)
        (ok true))
)

(define-public (set-price-validity-window (new-window uint))
    (begin
        (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
        (asserts! (and (>= new-window MIN_VALIDITY_WINDOW) 
                      (<= new-window MAX_VALIDITY_WINDOW)) ERR_INVALID_PARAMETER)
        (var-set price-validity-window new-window)
        (ok true))
)

;; Private Helper Functions

(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (check-expiry (option-id uint))
    (let (
        (option (unwrap! (map-get? options option-id) ERR_OPTION_NOT_FOUND))
        (current-height block-height)
    )
    (if (> current-height (get expiry option))
        ERR_OPTION_EXPIRED
        (ok true)
    ))
)

(define-private (update-user-balance (user principal) (delta uint) (is-subtract bool))
    (let (
        (current-balance (default-to {sbtc-balance: u0, locked-collateral: u0} 
                        (map-get? user-balances user)))
        (current-sbtc (get sbtc-balance current-balance))
        (new-balance (if is-subtract
                        (begin
                            (asserts! (>= current-sbtc delta) ERR_INSUFFICIENT_BALANCE)
                            (- current-sbtc delta))
                        (+ current-sbtc delta)))
    )
    (ok (map-set user-balances 
        user 
        (merge current-balance {sbtc-balance: new-balance})))
    )
)

;; Public Trading Functions

(define-public (deposit-sbtc (amount uint))
    (begin
        (asserts! (and (>= amount MIN_DEPOSIT_AMOUNT)
                      (<= amount MAX_DEPOSIT_AMOUNT)) ERR_INVALID_AMOUNT)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (try! (update-user-balance tx-sender amount false))
        (ok true)
    )
)

(define-public (create-option (option-type (string-ascii 4)) 
                            (strike-price uint)
                            (expiry uint)
                            (amount uint))
    (let (
        (option-id (var-get next-option-id))
        (required-collateral (/ (* amount strike-price) u100))
        (user-balance (default-to {sbtc-balance: u0, locked-collateral: u0} 
                     (map-get? user-balances tx-sender)))
    )
    (asserts! (or (is-eq option-type "CALL") (is-eq option-type "PUT")) 
              ERR_NOT_AUTHORIZED)
    (asserts! (>= strike-price u0) ERR_INVALID_STRIKE_PRICE)
    (asserts! (and (> expiry block-height)
                   (<= (- expiry block-height) u5200)) ERR_INVALID_EXPIRY)
    (asserts! (and (>= amount MIN_DEPOSIT_AMOUNT)
                   (<= amount MAX_DEPOSIT_AMOUNT)) ERR_INVALID_AMOUNT)
    (asserts! (>= (get sbtc-balance user-balance) required-collateral) 
              ERR_INSUFFICIENT_COLLATERAL)
    
    (try! (update-user-balance tx-sender required-collateral true))
    
    (map-set options option-id {
        creator: tx-sender,
        holder: tx-sender,
        option-type: option-type,
        strike-price: strike-price,
        expiry: expiry,
        amount: amount,
        collateral: required-collateral,
        status: "ACTIVE"
    })
    
    (map-set user-balances tx-sender
        (merge user-balance {
            locked-collateral: (+ (get locked-collateral user-balance) required-collateral)
        }))
    
    (var-set next-option-id (+ option-id u1))
    (ok option-id))
)