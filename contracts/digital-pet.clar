;; Digital Pet Contract
;; Users adopt pets that grow when consistently fed STX tokens

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-has-pet (err u101))
(define-constant err-no-pet (err u102))
(define-constant err-insufficient-payment (err u103))
(define-constant err-pet-full (err u104))

;; Minimum STX to feed pet (0.1 STX)
(define-constant min-feed-amount u100000)

;; Data Maps
(define-map pets
  principal
  {
    name: (string-ascii 20),
    hunger: uint,
    happiness: uint,
    size: uint,
    last-fed: uint,
    total-fed: uint,
    birth-block: uint
  }
)

(define-map pet-stats
  principal
  {
    total-pets: uint,
    active-pet: bool
  }
)

;; Public Functions

;; Adopt a new pet
(define-public (adopt-pet (pet-name (string-ascii 20)))
  (let
    (
      (sender tx-sender)
      (current-block block-height)
    )
    ;; Check if user already has a pet
    (asserts! (is-none (map-get? pets sender)) err-already-has-pet)

    ;; Create new pet
    (map-set pets sender
      {
        name: pet-name,
        hunger: u50,
        happiness: u50,
        size: u1,
        last-fed: current-block,
        total-fed: u0,
        birth-block: current-block
      }
    )

    ;; Update stats
    (map-set pet-stats sender
      {
        total-pets: u1,
        active-pet: true
      }
    )

    (ok true)
  )
)

;; Feed pet with STX
(define-public (feed-pet)
  (let
    (
      (sender tx-sender)
      (current-block block-height)
      (pet-data (unwrap! (map-get? pets sender) err-no-pet))
      (feed-amount min-feed-amount)
    )

    ;; Check if pet is too full (hunger must be > 0)
    (asserts! (> (get hunger pet-data) u0) err-pet-full)

    ;; Transfer STX to contract
    (try! (stx-transfer? feed-amount sender (as-contract tx-sender)))

    ;; Calculate blocks since last fed
    (let
      (
        (blocks-passed (- current-block (get last-fed pet-data)))
        (hunger-increase (if (> blocks-passed u10) u20 u0))
        (new-hunger (if (> (+ (get hunger pet-data) hunger-increase) u100)
                       u100
                       (+ (get hunger pet-data) hunger-increase)))
        (hunger-reduction u30)
        (updated-hunger (if (> new-hunger hunger-reduction)
                          (- new-hunger hunger-reduction)
                          u0))
        (new-happiness (if (< (get happiness pet-data) u80)
                         (+ (get happiness pet-data) u20)
                         u100))
        (new-total-fed (+ (get total-fed pet-data) feed-amount))
        ;; Pet grows every 1 STX fed (1000000 micro-STX)
        (new-size (+ u1 (/ new-total-fed u1000000)))
      )

      ;; Update pet
      (map-set pets sender
        (merge pet-data
          {
            hunger: updated-hunger,
            happiness: new-happiness,
            size: new-size,
            last-fed: current-block,
            total-fed: new-total-fed
          }
        )
      )

      (ok {
        hunger: updated-hunger,
        happiness: new-happiness,
        size: new-size,
        fed-amount: feed-amount
      })
    )
  )
)

;; Release pet (abandon)
(define-public (release-pet)
  (let
    (
      (sender tx-sender)
    )
    ;; Check if user has a pet
    (asserts! (is-some (map-get? pets sender)) err-no-pet)

    ;; Delete pet
    (map-delete pets sender)

    ;; Update stats
    (map-set pet-stats sender
      {
        total-pets: u1,
        active-pet: false
      }
    )

    (ok true)
  )
)

;; Read-only functions

;; Get pet info
(define-read-only (get-pet-info (owner principal))
  (map-get? pets owner)
)

;; Get pet stats
(define-read-only (get-pet-stats (owner principal))
  (map-get? pet-stats owner)
)

;; Check if pet is hungry (hunger > 70)
(define-read-only (is-pet-hungry (owner principal))
  (match (map-get? pets owner)
    pet-data (ok (> (get hunger pet-data) u70))
    (err err-no-pet)
  )
)

;; Check if pet is happy (happiness > 50)
(define-read-only (is-pet-happy (owner principal))
  (match (map-get? pets owner)
    pet-data (ok (> (get happiness pet-data) u50))
    (err err-no-pet)
  )
)

;; Get pet age in blocks
(define-read-only (get-pet-age (owner principal))
  (match (map-get? pets owner)
    pet-data (ok (- block-height (get birth-block pet-data)))
    (err err-no-pet)
  )
)

;; Calculate current hunger level (increases over time)
(define-read-only (get-current-hunger (owner principal))
  (match (map-get? pets owner)
    pet-data
      (let
        (
          (blocks-passed (- block-height (get last-fed pet-data)))
          (hunger-increase (/ blocks-passed u10))
          (current-hunger (+ (get hunger pet-data) hunger-increase))
        )
        (ok (if (> current-hunger u100) u100 current-hunger))
      )
    (err err-no-pet)
  )
)
