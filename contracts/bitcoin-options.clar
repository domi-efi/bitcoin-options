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