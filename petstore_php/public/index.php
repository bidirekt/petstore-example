<?php

use Petstore\Pet;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';

$app = AppFactory::create();
$app->addBodyParsingMiddleware();

$pets = [];

function json(Response $response, Pet $pet, int $status): Response
{
    // The contract says weight is a float, so 0.0 must not be written as 0.
    $response->getBody()->write((string) json_encode($pet, JSON_PRESERVE_ZERO_FRACTION));

    return $response->withStatus($status)->withHeader('Content-Type', 'application/json');
}

/**
 * @bidirekt provides GET /pets/*
 * @bidirekt response 200 Pet
 * @bidirekt response 404
 */
$app->get('/pets/{id}', function (Request $request, Response $response, array $args) use (&$pets): Response {
    foreach ($pets as $pet) {
        if ($pet->petId === (int) $args['id']) {
            return json($response, $pet, 200);
        }
    }

    return $response->withStatus(404);
});

/**
 * @bidirekt provides POST /pets
 * @bidirekt request NewPet
 * @bidirekt response 201 Pet
 * @bidirekt response 400
 */
$app->post('/pets', function (Request $request, Response $response) use (&$pets): Response {
    $body = $request->getParsedBody();
    if (!is_array($body) || !is_string($body['name'] ?? null) || !is_int($body['ownerId'] ?? null)) {
        return $response->withStatus(400);
    }
    $pet = new Pet(count($pets) + 1, $body['name'], 'available', 0.0);
    $pets[] = $pet;

    return json($response, $pet, 201);
});

$app->run();
