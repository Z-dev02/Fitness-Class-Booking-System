;; Section 1: Core Infrastructure and Constants
;; Basic setup, error constants, and data variables

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-class-not-found (err u101))
(define-constant err-class-full (err u102))
(define-constant err-insufficient-payment (err u103))
(define-constant err-already-booked (err u104))
(define-constant err-booking-not-found (err u105))
(define-constant err-instructor-not-found (err u106))
(define-constant err-membership-not-found (err u107))
(define-constant err-membership-expired (err u108))
(define-constant err-invalid-rating (err u109))
(define-constant err-class-already-started (err u110))
(define-constant err-unauthorized (err u111))
(define-constant err-invalid-discount (err u112))
(define-constant err-waitlist-full (err u113))
(define-constant err-class-cancelled (err u114))
(define-constant err-package-not-found (err u115))

(define-data-var next-class-id uint u1)
(define-data-var next-booking-id uint u1)
(define-data-var next-instructor-id uint u1)
(define-data-var next-membership-id uint u1)
(define-data-var next-package-id uint u1)
(define-data-var max-waitlist-size uint u10)
(define-data-var cancellation-fee uint u5)

;; Section 2: Data Structure Definitions
;; All map definitions for storing application data

(define-map fitness-classes
  { class-id: uint }
  {
    class-name: (string-ascii 50),
    instructor-id: uint,
    class-time: uint,
    duration: uint,
    max-capacity: uint,
    current-bookings: uint,
    price: uint,
    class-type: (string-ascii 30),
    status: (string-ascii 20),
    description: (string-ascii 200),
    difficulty-level: (string-ascii 20),
    equipment-needed: (string-ascii 100),
    location: (string-ascii 50),
    waitlist-count: uint
  })

(define-map class-bookings
  { booking-id: uint }
  {
    class-id: uint,
    student: principal,
    booking-time: uint,
    payment-amount: uint,
    status: (string-ascii 20),
    payment-method: (string-ascii 20),
    notes: (string-ascii 100)
  })

(define-map user-class-bookings
  { user: principal, class-id: uint }
  { booking-id: uint, status: (string-ascii 20) })

(define-map instructors
  { instructor-id: uint }
  {
    name: (string-ascii 50),
    bio: (string-ascii 200),
    specialties: (string-ascii 100),
    certification: (string-ascii 50),
    rating: uint,
    total-ratings: uint,
    hourly-rate: uint,
    status: (string-ascii 20)
  })

(define-map memberships
  { membership-id: uint }
  {
    user: principal,
    membership-type: (string-ascii 30),
    start-date: uint,
    end-date: uint,
    classes-remaining: uint,
    status: (string-ascii 20),
    discount-rate: uint
  })

(define-map class-packages
  { package-id: uint }
  {
    package-name: (string-ascii 50),
    class-count: uint,
    price: uint,
    validity-days: uint,
    discount-rate: uint,
    package-type: (string-ascii 30)
  })

(define-map user-packages
  { user: principal, package-id: uint }
  {
    purchase-date: uint,
    classes-used: uint,
    expiry-date: uint,
    status: (string-ascii 20)
  })

(define-map class-ratings
  { class-id: uint, user: principal }
  {
    rating: uint,
    review: (string-ascii 200),
    rating-date: uint
  })

(define-map waitlist
  { class-id: uint, user: principal }
  {
    join-time: uint,
    position: uint,
    status: (string-ascii 20)
  })

(define-map class-attendance
  { class-id: uint, user: principal }
  {
    attended: bool,
    check-in-time: uint,
    notes: (string-ascii 100)
  })

(define-map recurring-classes
  { class-id: uint }
  {
    recurrence-pattern: (string-ascii 20),
    end-date: uint,
    next-occurrence: uint,
    total-occurrences: uint
  })

  ;; Section 3: Administrative Functions
;; Owner-only functions for system management

(define-public (create-class
  (class-name (string-ascii 50))
  (instructor-id uint)
  (class-time uint)
  (duration uint)
  (max-capacity uint)
  (price uint)
  (class-type (string-ascii 30))
  (description (string-ascii 200))
  (difficulty-level (string-ascii 20))
  (equipment-needed (string-ascii 100))
  (location (string-ascii 50)))
  (let ((class-id (var-get next-class-id)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some (map-get? instructors { instructor-id: instructor-id })) err-instructor-not-found)
      (map-set fitness-classes { class-id: class-id }
        {
          class-name: class-name,
          instructor-id: instructor-id,
          class-time: class-time,
          duration: duration,
          max-capacity: max-capacity,
          current-bookings: u0,
          price: price,
          class-type: class-type,
          status: "active",
          description: description,
          difficulty-level: difficulty-level,
          equipment-needed: equipment-needed,
          location: location,
          waitlist-count: u0
        })
      (var-set next-class-id (+ class-id u1))
      (ok class-id))))

(define-public (register-instructor
  (name (string-ascii 50))
  (bio (string-ascii 200))
  (specialties (string-ascii 100))
  (certification (string-ascii 50))
  (hourly-rate uint))
  (let ((instructor-id (var-get next-instructor-id)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (map-set instructors { instructor-id: instructor-id }
        {
          name: name,
          bio: bio,
          specialties: specialties,
          certification: certification,
          rating: u0,
          total-ratings: u0,
          hourly-rate: hourly-rate,
          status: "active"
        })
      (var-set next-instructor-id (+ instructor-id u1))
      (ok instructor-id))))

(define-public (create-membership
  (user principal)
  (membership-type (string-ascii 30))
  (duration-days uint)
  (classes-included uint)
  (discount-rate uint))
  (let 
    ((membership-id (var-get next-membership-id))
     (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
     (end-date (+ current-time (* duration-days u86400))))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (map-set memberships { membership-id: membership-id }
        {
          user: user,
          membership-type: membership-type,
          start-date: current-time,
          end-date: end-date,
          classes-remaining: classes-included,
          status: "active",
          discount-rate: discount-rate
        })
      (var-set next-membership-id (+ membership-id u1))
      (ok membership-id))))

(define-public (create-package
  (package-name (string-ascii 50))
  (class-count uint)
  (price uint)
  (validity-days uint)
  (discount-rate uint)
  (package-type (string-ascii 30)))
  (let ((package-id (var-get next-package-id)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (map-set class-packages { package-id: package-id }
        {
          package-name: package-name,
          class-count: class-count,
          price: price,
          validity-days: validity-days,
          discount-rate: discount-rate,
          package-type: package-type
        })
      (var-set next-package-id (+ package-id u1))
      (ok package-id))))

(define-public (mark-attendance (class-id uint) (user principal))
  (let ((current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      
      (map-set class-attendance { class-id: class-id, user: user }
        {
          attended: true,
          check-in-time: current-time,
          notes: ""
        })
      
      (ok true))))

(define-public (update-class-status (class-id uint) (new-status (string-ascii 20)))
  (let ((class-info (unwrap! (map-get? fitness-classes { class-id: class-id }) err-class-not-found)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      
      (map-set fitness-classes { class-id: class-id }
        (merge class-info { status: new-status }))
      
      (ok true))))

(define-public (set-cancellation-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set cancellation-fee new-fee)
    (ok true)))

    