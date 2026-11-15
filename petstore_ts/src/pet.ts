import { BidirektField, BidirektSchema } from '@bidirekt/typescript-sdk'

@BidirektSchema()
export class Pet {
  @BidirektField({ type: 'integer' })
  petId!: number

  @BidirektField()
  name!: string

  @BidirektField()
  status!: string

  @BidirektField({ type: 'float' })
  weight!: number
}

@BidirektSchema()
export class NewPet {
  @BidirektField()
  name!: string

  @BidirektField({ type: 'integer' })
  ownerId!: number
}
