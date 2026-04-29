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
        'categoria_id' => 'required|exists:categorias,id',
        'recorrente' => 'required|boolean',
        'imagem' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Validação da imagem
    ]);

    if ($validator->fails()) {
        return response()->json([
            'status' => 'erro',
            'erros' => $validator->errors()
        ], 422);
    }

    $data = $request->only(['title', 'content', 'valor', 'categoria_id', 'recorrente']);
    $data['user_id'] = $request->user()->id;

    // DEBUG: Verificar se imagem foi enviada
    \Log::info('DEBUG Store - Request hasFile imagem: ' . ($request->hasFile('imagem') ? 'SIM' : 'NAO'));
    \Log::info('DEBUG Store - Request file imagem: ' . ($request->file('imagem') ? 'SIM' : 'NAO'));

    // Upload da imagem se existir
    if ($request->hasFile('imagem')) {
        $path = $request->file('imagem')->store('comprovantes', 'public');
        $data['imagem'] = $path;
        \Log::info('DEBUG Store - Imagem salva em: ' . $path);
    } else {
        \Log::info('DEBUG Store - Nenhuma imagem para salvar');
    }

    $post = Post::create($data);
    \Log::info('DEBUG Store - Post criado com ID: ' . $post->id . ', imagem: ' . ($post->imagem ?? 'null'));

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
            'imagem' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Validação da imagem
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'erro',
                'erros' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['title', 'content', 'valor', 'categoria_id', 'recorrente']);

        // DEBUG: Verificar se imagem foi enviada
        \Log::info('DEBUG Update - Post ID: ' . $id . ', imagem atual: ' . ($post->imagem ?? 'null'));
        \Log::info('DEBUG Update - Request hasFile imagem: ' . ($request->hasFile('imagem') ? 'SIM' : 'NAO'));

        // Upload da nova imagem se existir
        if ($request->hasFile('imagem')) {
            // Remove a imagem antiga se existir
            if ($post->imagem && \Storage::disk('public')->exists($post->imagem)) {
                \Storage::disk('public')->delete($post->imagem);
                \Log::info('DEBUG Update - Imagem antiga removida: ' . $post->imagem);
            }

            $path = $request->file('imagem')->store('comprovantes', 'public');
            $data['imagem'] = $path;
            \Log::info('DEBUG Update - Nova imagem salva em: ' . $path);
        } else {
            \Log::info('DEBUG Update - Nenhuma nova imagem para salvar');
        }

        $post->update($data);
        \Log::info('DEBUG Update - Post atualizado, nova imagem: ' . ($post->fresh()->imagem ?? 'null'));

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

    public function getCategorias()
    {
        $categorias = \App\Models\Categoria::all();
        return response()->json($categorias);
    }
}