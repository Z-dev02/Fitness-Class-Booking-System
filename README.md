# Fitness Class Booking System

A decentralized booking platform for fitness classes built on the Stacks blockchain, enabling transparent class scheduling and secure payment processing.

## Features

- **Class Management**: Create and manage fitness classes with detailed information
- **Real-time Booking**: Instant booking with capacity management
- **Payment Integration**: Secure STX-based payment processing  
- **Booking History**: Complete audit trail of all bookings
- **Cancellation System**: Flexible booking cancellation with automatic refund processing
- **Multi-class Support**: Support for various fitness class types

## Class Types Supported

- Yoga Classes
- HIIT Workouts  
- Pilates Sessions
- Spin Classes
- Strength Training
- Dance Fitness

## Smart Contract Functions

### Public Functions
- `create-class`: Add new fitness class to schedule (owner only)
- `book-class`: Book a spot in available fitness class
- `cancel-booking`: Cancel existing booking with refund

### Read-Only Functions
- `get-class-info`: Retrieve detailed class information
- `get-booking-info`: Get specific booking details
- `get-user-booking`: Check user's booking status for specific class
- `get-next-class-id`: Get next available class ID
- `get-next-booking-id`: Get next booking ID

## Booking Workflow

1. **Class Creation**: Gym owner creates class with schedule and pricing
2. **User Booking**: Users browse and book available classes
3. **Payment Processing**: Automatic STX payment handling
4. **Confirmation**: Booking confirmed with unique booking ID
5. **Class Attendance**: Users attend class with verified booking
6. **Optional Cancellation**: Users can cancel with automatic processing

## Benefits

- **Transparency**: All bookings recorded on blockchain
- **Security**: Cryptographic security for payments
- **Automation**: Reduced manual booking management
- **Global Access**: Book classes from anywhere
- **Fair Access**: First-come-first-served booking system

## Technology Stack

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Payment Token**: STX
- **Storage**: On-chain booking records

## Getting Started

1. Deploy contract to Stacks testnet/mainnet
2. Create initial fitness class offerings
3. Set up frontend booking interface
4. Begin accepting class bookings