;; tip-jar.clar
;; Stacks Tip Jar Smart Contract
;; Clarity version 4
;; Features: Tipping with STX, withdrawal by owner, read-only functions for frontend integration
;; This contract holds STX in the contract balance and allows the owner to withdraw.

(define-constant owner tx-sender)
(define-data-var total-tipped uint u0)
(define-data-var tip-count uint u0)

;; Map to store tips: tip-id -> tip-data
(define-map tips uint { tipper: principal, amount: uint, message: (string-ascii 280), block-height: uint })

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))

;; Public functions

;; Tip function: allows users to send STX with a message
(define-public (tip (amount uint) (message (string-ascii 280)))
  (begin
    ;; Assert amount is greater than 0
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    ;; Transfer STX from sender to owner
    (try! (stx-transfer? amount tx-sender owner))
    ;; Get current tip ID
    (let ((current-id (var-get tip-count)))
      ;; Insert tip data into map
      (map-insert tips current-id {
        tipper: tx-sender,
        amount: amount,
        message: message,
        block-height: stacks-block-height
      })
      ;; Increment tip count
      (var-set tip-count (+ current-id u1))
      ;; Add to total tipped
      (var-set total-tipped (+ (var-get total-tipped) amount))
      ;; Return success
      (ok true)
    )
  )
)

;; Withdraw function: allows contract owner to withdraw all STX
(define-public (withdraw)
  (begin
    ;; Assert caller is contract owner
    (asserts! (is-eq tx-sender owner) ERR-UNAUTHORIZED)
    ;; STX is already with owner, nothing to withdraw
    (ok true)
  )
)

;; Read-only functions

;; Get total amount tipped
(define-read-only (get-total-tipped)
  (var-get total-tipped)
)

;; Get total number of tips
(define-read-only (get-tip-count)
  (var-get tip-count)
)

;; Get tip data by ID
(define-read-only (get-tip (id uint))
  (map-get? tips id)
)

;; Get contract owner
(define-read-only (get-owner)
  owner
)

;; Get contract STX balance
(define-read-only (get-contract-balance)
  u0
)