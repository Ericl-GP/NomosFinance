<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{   

public function register(Request $request)
{
    // 1. Validação Manual controlada
    $validator = Validator::make($request->all(), [
        'name' => 'required|string|max:255',
        'email' => 'required|string|email|max:255|unique:users',
        'password' => 'required|string|min:6',
    ]);

    // Se a validação falhar, forçamos o retorno em JSON com status 422
    if ($validator->fails()) {
        return response()->json([
            'message' => 'Os dados fornecidos são inválidos.',
            'errors' => $validator->errors()
        ], 422);
    }

    // Pega os dados validados limpos
    $validatedData = $validator->validated();

    // 2. Criação do usuário
    $user = User::create([
        'name' => $validatedData['name'],
        'email' => $validatedData['email'],
        'password' => Hash::make($validatedData['password']),
    ]);

    // 3. Geração do token
    $token = $user->createToken('auth_token')->plainTextToken;

    // 4. Retorno
    return response()->json([
        'message' => 'Usuário registrado com sucesso',
        'access_token' => $token,
        'token_type' => 'Bearer',
        'user' => $user
    ], 201);
}
    public function login(Request $request)
{
    // 1. Validação Manual controlada
    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'password' => 'required',
    ]);

    // Se a validação falhar (ex: e-mail em branco), retorna JSON com status 422
    if ($validator->fails()) {
        return response()->json([
            'message' => 'Os dados fornecidos são inválidos.',
            'errors' => $validator->errors()
        ], 422);
    }

    // 2. Busca o usuário pelo e-mail
    $user = User::where('email', $request->email)->first();

    // 3. Verifica se o usuário existe e se a senha confere
    if (! $user || ! Hash::check($request->password, $user->password)) {
        // Retorna status 401 (Unauthorized) para credenciais incorretas
        return response()->json([
            'message' => 'Credenciais inválidas. Verifique seu e-mail e senha.'
        ], 401);
    }

    // 4. Cria o token de acesso
    $token = $user->createToken('auth_token')->plainTextToken;

    // 5. Retorno padronizado em JSON com status 200 (OK)
    return response()->json([
        'message' => 'Login realizado com sucesso',
        'access_token' => $token,
        'token_type' => 'Bearer',
        'user' => $user
    ], 200);
}

    // Método de Logout (Requer autenticação)
    public function logout(Request $request)
    {
        // Deleta o token atual que foi usado para a requisição
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout realizado com sucesso'
        ], 200);
    }
}