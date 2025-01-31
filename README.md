# Bitcoin Options: Decentralized Bitcoin Options Trading Protocol

A sophisticated decentralized options trading protocol built on Stacks L2, enabling secure and efficient Bitcoin-settled options trading with automated execution and robust price oracle integration.

## Overview

Bitcoin Options revolutionizes Bitcoin options trading by providing a trustless, fully-collateralized platform that leverages Stacks' Bitcoin L2 capabilities. The protocol enables users to create, trade, and settle Bitcoin options in a decentralized manner.

## Features

- **Automated Options Trading**
  - Create CALL and PUT options
  - Automated settlement and exercise
  - Configurable strike prices and expiry dates
  - Trustless execution

- **Robust Price Oracle Integration**
  - Real-time BTC price feeds
  - Configurable price validity windows
  - Stale price protection
  - Oracle address management

- **Advanced Collateral Management**
  - Dynamic collateral requirements
  - Automated collateral locking/unlocking
  - Configurable collateral ratios
  - Protected collateral release

- **Security Features**
  - Role-based access control
  - Owner-only administrative functions
  - Balance validation
  - Comprehensive error handling

## Technical Specifications

### Protocol Parameters

- Maximum Fee: 100% (10000 basis points)
- Maximum Collateral Ratio: 1000%
- Minimum Deposit: 1000 satoshis
- Maximum Deposit: 1000 BTC
- Price Validity Window: 10-1440 blocks (~10 min to 24 hours)
- Default Collateral Ratio: 150%
- Default Platform Fee: 0.1% (10 basis points)

### Data Structures

#### Option Contract
```clarity
{
    creator: principal,
    holder: principal,
    option-type: string-ascii,  // "CALL" or "PUT"
    strike-price: uint,
    expiry: uint,
    amount: uint,
    collateral: uint,
    status: string-ascii  // "ACTIVE", "EXERCISED", "EXPIRED"
}
```

#### User Balance
```clarity
{
    sbtc-balance: uint,
    locked-collateral: uint
}
```

## Core Functions

### Trading Functions

#### `deposit-sbtc`
Deposit sBTC into the protocol for trading or collateral.
```clarity
(define-public (deposit-sbtc (amount uint)))
```

#### `create-option`
Create a new option contract with specified parameters.
```clarity
(define-public (create-option 
    (option-type (string-ascii 4)) 
    (strike-price uint)
    (expiry uint)
    (amount uint)))
```

#### `exercise-option`
Exercise an active option contract if conditions are met.
```clarity
(define-public (exercise-option (option-id uint)))
```

#### `expire-option`
Expire an option and return collateral after expiration.
```clarity
(define-public (expire-option (option-id uint)))
```

### Oracle Functions

#### `update-btc-price`
Update the current BTC price (oracle only).
```clarity
(define-public (update-btc-price (new-price uint)))
```

#### `get-current-btc-price`
Get the current valid BTC price.
```clarity
(define-read-only (get-current-btc-price))
```

### Administrative Functions

#### `set-platform-fee`
Update the platform fee (owner only).
```clarity
(define-public (set-platform-fee (new-fee uint)))
```

#### `set-min-collateral-ratio`
Update the minimum collateral ratio (owner only).
```clarity
(define-public (set-min-collateral-ratio (new-ratio uint)))
```

## Error Handling

The protocol includes comprehensive error handling with specific error codes:

- `ERR_NOT_AUTHORIZED (100)`: Unauthorized access attempt
- `ERR_INVALID_AMOUNT (101)`: Invalid amount specified
- `ERR_INSUFFICIENT_BALANCE (102)`: Insufficient balance for operation
- `ERR_OPTION_NOT_FOUND (103)`: Option ID not found
- `ERR_OPTION_EXPIRED (104)`: Option has expired
- `ERR_INVALID_STRIKE_PRICE (105)`: Invalid strike price specified
- `ERR_INVALID_EXPIRY (106)`: Invalid expiry date
- `ERR_INSUFFICIENT_COLLATERAL (107)`: Insufficient collateral
- `ERR_OPTION_NOT_EXERCISABLE (108)`: Option cannot be exercised
- `ERR_STALE_PRICE (109)`: Price feed is stale
- `ERR_INVALID_PRICE (110)`: Invalid price provided
- `ERR_OPTION_NOT_EXPIRED (111)`: Option has not expired
- `ERR_INVALID_PARAMETER (112)`: Invalid parameter provided

## Security Considerations

1. **Collateral Management**
   - All options are fully collateralized
   - Collateral is locked until option expiry or exercise
   - Automatic collateral release on expiration

2. **Price Oracle Security**
   - Price validity window enforcement
   - Stale price protection
   - Authorized oracle updates only

3. **Access Control**
   - Owner-only administrative functions
   - Protected oracle updates
   - Validated option operations

4. **Balance Protection**
   - Balance checks before operations
   - Safe arithmetic operations
   - Protected collateral release

## License

MIT License

## Contributing

We welcome contributions to Bitcoin Options! Please see our contributing guidelines for more information.

## Support

For support, please open an issue in the GitHub repository or contact the development team.