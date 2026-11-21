package main

type Pet struct {
	PetID  int     `json:"petId" bidirekt:"field"`
	Name   string  `json:"name" bidirekt:"field"`
	Status string  `json:"status" bidirekt:"field"`
	Weight float64 `json:"weight" bidirekt:"field"`
}

type NewPet struct {
	Name    string `json:"name" bidirekt:"field"`
	OwnerID int    `json:"ownerId" bidirekt:"field"`
}
