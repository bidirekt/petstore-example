<?php

namespace Petstore;

use Bidirekt\PhpSdk\BidirektField;
use Bidirekt\PhpSdk\BidirektSchema;

#[BidirektSchema]
final class Pet
{
    public function __construct(
        #[BidirektField] public int $petId,
        #[BidirektField] public string $name,
        #[BidirektField] public string $status,
        #[BidirektField(type: 'float')] public float $weight,
    ) {
    }
}
