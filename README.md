🐾 Digital Pet Smart Contract

Overview

The Digital Pet Contract allows users to adopt, feed, and care for virtual pets directly on the Stacks blockchain.
Each pet has attributes like hunger, happiness, size, and age, which evolve based on player interactions and on-chain activity.
By feeding their pets with STX tokens, users can help them grow, stay happy, and reduce hunger over time.

🌟 Key Features
1. Adopt a Pet

Users can adopt a unique pet by providing a name.

Each user may own only one active pet at a time.

Newly adopted pets start with balanced stats (hunger = 50, happiness = 50, size = 1).

2. Feed a Pet

Pets can be fed using 0.1 STX (100,000 micro-STX).

Feeding reduces hunger and increases happiness.

Feeding also contributes to growth — for every 1 STX total fed, the pet’s size increases by 1.

If a pet hasn’t been fed for a long time, its hunger level will rise based on the number of blocks passed.

3. Release a Pet

Users can release (abandon) their pets, deleting all associated data while keeping their stats record.

4. Pet Growth Mechanics

Hunger increases over time if not fed.

Happiness rises with consistent feeding.

Size grows cumulatively as more STX is spent feeding.

🧠 Data Structures
Maps

pets → Stores each user’s pet information:

{
  name: string,
  hunger: uint,
  happiness: uint,
  size: uint,
  last-fed: uint,
  total-fed: uint,
  birth-block: uint
}


pet-stats → Tracks user-level statistics:

{
  total-pets: uint,
  active-pet: bool
}

⚙️ Public Functions
Function	Description
adopt-pet (pet-name)	Creates a new pet for the sender if they don’t already own one.
feed-pet	Feeds the pet with a fixed 0.1 STX payment, adjusting hunger, happiness, and growth.
release-pet	Deletes the user’s pet and marks them as inactive.
🔍 Read-Only Functions
Function	Description
get-pet-info (owner)	Returns full pet data for the specified user.
get-pet-stats (owner)	Returns the user’s total pets and active status.
is-pet-hungry (owner)	Checks if hunger level > 70.
is-pet-happy (owner)	Checks if happiness level > 50.
get-pet-age (owner)	Returns pet age in blocks since birth.
get-current-hunger (owner)	Calculates hunger increase based on time since last fed.
💰 Token Logic

Feeding requires 0.1 STX, transferred from the user to the contract.

The feed-pet function uses stx-transfer? to securely process payments.

🧾 Error Codes
Code	Meaning
u100	Sender is not the contract owner.
u101	User already owns a pet.
u102	User does not have a pet.
u103	Insufficient STX sent.
u104	Pet is too full to be fed again.
🚀 Example Interaction Flow

Adopt a pet:

(contract-call? .digital-pet adopt-pet "Fluffy")


Feed your pet:

(contract-call? .digital-pet feed-pet)


Check your pet’s info:

(contract-call? .digital-pet get-pet-info tx-sender)


Release your pet:

(contract-call? .digital-pet release-pet)

🧩 Future Improvements

Introduce pet evolution levels (e.g., Baby → Teen → Adult).

Add NFT representation for each pet.

Enable trading or gifting of pets between users.

Add leaderboards for the happiest or largest pets.

📜 License

This project is open-source and available under the MIT License.