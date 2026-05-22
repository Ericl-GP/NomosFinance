<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            // Adiciona o campo 'data' logo após o campo 'imagem'
            // Usamos dateTime para guardar data e hora, ideal para o calendário e notificações
            $table->dateTime('data')->useCurrent()->after('imagem');
        });
    }

    public function down(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            // Remove a coluna caso decidas fazer um rollback da migration
            $table->dropColumn('data');
        });
    }
};