<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Post;
use Illuminate\Support\Facades\Validator;

class PostController extends Controller
{
    public function index(Request $request)
    {
        $searchTerm = $request->query('search');

        $posts = Post::query()
            ->where('user_id', $request->user()->id) // mostra só posts do usuário logado
            ->when($searchTerm, function ($query, $searchTerm) {
                return $query->where(function ($q) use ($searchTerm) {
                    $q->where('title', 'like', "%{$searchTerm}%")
                      ->orWhere('content', 'like', "%{$searchTerm}%");
                });
            })
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($posts);
    }

   public function store(Request $request)
{
    $validator = Validator::make($request->all(), [
        'title' => 'required|string|max:255',
        'content' => 'required|string',
        'valor' => 'required|numeric',
        'categoria_id' => 'required|exists:categorias,id', // Valida se o ID existe na tabela categorias
        'recorrente' => 'required|boolean',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'status' => 'erro',
            'erros' => $validator->errors()
        ], 422);
    }

    $post = Post::create([
        'title' => $request->title,
        'content' => $request->content,
        'valor' => $request->valor,
        'categoria_id' => $request->categoria_id,
        'recorrente' => $request->recorrente,
        'user_id' => $request->user()->id
    ]);

    return response()->json($post, 201);
}

    public function show(Request $request, string $id)
    {
        $post = Post::find($id);

        if (! $post) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        if ($post->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Acesso negado'], 403);
        }

        return response()->json($post, 200);
    }

    public function update(Request $request, string $id)
    {
        $post = Post::find($id);

        if (! $post) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        if ($post->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Acesso negado'], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'valor' => 'required|numeric',
            'categoria_id' => 'required|exists:categorias,id',
            'recorrente' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'erro',
                'erros' => $validator->errors()
            ], 422);
        }

        $post->update($validator->validated());

        return response()->json($post, 200);
    }

    public function destroy(Request $request, string $id)
    {
        $post = Post::find($id);

        if (! $post) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        if ($post->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Acesso negado'], 403);
        }

        $post->delete();

        return response()->json(['message' => 'Post deleted'], 200);
    }

    public function postsByUser(Request $request, $id)
    {
        // Segurança: só permite acessar os próprios posts
        if ((int) $id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Acesso negado'], 403);
        }

        $posts = Post::where('user_id', $id)->orderBy('created_at', 'desc')->get();

        return response()->json($posts);
    }
}