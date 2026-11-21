package main

import (
	"cmp"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync"

	"github.com/bidirekt/go-sdk"
)

type petStore struct {
	mutex sync.Mutex
	pets  map[int]Pet
}

var _ = bidirekt.Provides(http.MethodGet, "/pets/*",
	bidirekt.Response(http.StatusOK, Pet{}),
	bidirekt.Response(http.StatusNotFound, nil),
)

func (this *petStore) getPet(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	this.mutex.Lock()
	pet, found := this.pets[id]
	this.mutex.Unlock()
	if err != nil || !found {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	writePet(w, http.StatusOK, pet)
}

var _ = bidirekt.Provides(http.MethodPost, "/pets",
	bidirekt.Request(NewPet{}),
	bidirekt.Response(http.StatusCreated, Pet{}),
	bidirekt.Response(http.StatusBadRequest, nil),
)

func (this *petStore) createPet(w http.ResponseWriter, r *http.Request) {
	var newPet NewPet
	if err := json.NewDecoder(r.Body).Decode(&newPet); err != nil || newPet.Name == "" || newPet.OwnerID == 0 {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	this.mutex.Lock()
	pet := Pet{PetID: len(this.pets) + 1, Name: newPet.Name, Status: "available"}
	this.pets[pet.PetID] = pet
	this.mutex.Unlock()
	writePet(w, http.StatusCreated, pet)
}

func writePet(w http.ResponseWriter, status int, pet Pet) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(pet)
}

func main() {
	store := &petStore{pets: map[int]Pet{}}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /pets/{id}", store.getPet)
	mux.HandleFunc("POST /pets", store.createPet)

	port := cmp.Or(os.Getenv("PORT"), "3000")
	log.Printf("petstore_go listening on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}
