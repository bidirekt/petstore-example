<?php

namespace Petstore;

use Bidirekt\PhpSdk\BidirektField;
use Bidirekt\PhpSdk\BidirektSchema;

#[BidirektSchema]
final class NewPet
{
    public function __construct(
        #[BidirektField] public string $name,
        #[BidirektField] public int $ownerId,
    ) {
    }
}
