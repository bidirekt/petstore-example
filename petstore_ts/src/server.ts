import express from 'express'
import { Pet, type NewPet } from './pet.js'

const pets: Array<Pet> = []

const app = express()
app.use(express.json())

/**
 * @bidirekt provides GET /pets/*
 * @bidirekt response 200 Pet
 * @bidirekt response 404
 */
app.get('/pets/:id', (req, res) => {
  const pet = pets.find((candidate) => candidate.petId === Number(req.params.id))
  if (pet === undefined) {
    res.sendStatus(404)
    return
  }
  res.json(pet)
})

/**
 * @bidirekt provides POST /pets
 * @bidirekt request NewPet
 * @bidirekt response 201 Pet
 * @bidirekt response 400
 */
app.post('/pets', (req, res) => {
  const body = req.body as Partial<NewPet> | undefined
  if (typeof body?.name !== 'string' || !Number.isInteger(body.ownerId)) {
    res.sendStatus(400)
    return
  }
  const pet = new Pet()
  pet.petId = pets.length + 1
  pet.name = body.name
  pet.status = 'available'
  pet.weight = 0
  pets.push(pet)
  res.status(201).json(pet)
})

const port = Number(process.env.PORT ?? 3000)
app.listen(port, () => {
  console.log(`petstore_ts listening on port ${port}`)
})
