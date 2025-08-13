import sqlite3
import tkinter as tk
from tkinter import messagebox, ttk

# Banco de dados
conn = sqlite3.connect("alunos.db")
cursor = conn.cursor()
cursor.execute("""
CREATE TABLE IF NOT EXISTS alunos (
    matricula TEXT PRIMARY KEY,
    nome TEXT NOT NULL,
    nota REAL NOT NULL
)
""")
conn.commit()

# Funções
def cadastrar():
    m = entry_matricula.get()
    n = entry_nome.get()
    nota = entry_nota.get()

    if not (m and n and nota):
        messagebox.showwarning("Atenção", "Preencha todos os campos!")
        return

    try:
        cursor.execute("INSERT INTO alunos (matricula, nome, nota) VALUES (?, ?, ?)", (m, n, float(nota)))
        conn.commit()
        messagebox.showinfo("Sucesso", "Aluno cadastrado!")
        limpar_campos()
        atualizar_tabela()
    except sqlite3.IntegrityError:
        messagebox.showerror("Erro", "Matrícula já cadastrada.")
    except ValueError:
        messagebox.showerror("Erro", "Nota inválida.")

def atualizar():
    m = entry_matricula.get()
    nova_nota = entry_nota.get()

    if not (m and nova_nota):
        messagebox.showwarning("Atenção", "Preencha matrícula e nova nota.")
        return
    try:
        cursor.execute("UPDATE alunos SET nota = ? WHERE matricula = ?", (float(nova_nota), m))
        if cursor.rowcount == 0:
            messagebox.showinfo("Info", "Aluno não encontrado.")
        else:
            conn.commit()
            messagebox.showinfo("Sucesso", "Nota atualizada!")
            limpar_campos()
            atualizar_tabela()
    except ValueError:
        messagebox.showerror("Erro", "Nota inválida.")

def deletar():
    m = entry_matricula.get()
    if not m:
        messagebox.showwarning("Atenção", "Informe a matrícula.")
        return
    cursor.execute("DELETE FROM alunos WHERE matricula = ?", (m,))
    if cursor.rowcount == 0:
        messagebox.showinfo("Info", "Aluno não encontrado.")
    else:
        conn.commit()
        messagebox.showinfo("Sucesso", "Aluno deletado!")
        limpar_campos()
        atualizar_tabela()

def limpar_campos():
    entry_matricula.delete(0, tk.END)
    entry_nome.delete(0, tk.END)
    entry_nota.delete(0, tk.END)

def atualizar_tabela():
    for row in tree.get_children():
        tree.delete(row)

    cursor.execute("SELECT * FROM alunos")
    for m, n, nota in cursor.fetchall():
        tree.insert("", "end", values=(m, n, nota))

# Janela
janela = tk.Tk()
janela.title("Cadastro de Alunos")
janela.geometry("500x400")

# Entradas
tk.Label(janela, text="Matrícula:").pack()
entry_matricula = tk.Entry(janela)
entry_matricula.pack()

tk.Label(janela, text="Nome:").pack()
entry_nome = tk.Entry(janela)
entry_nome.pack()

tk.Label(janela, text="Nota:").pack()
entry_nota = tk.Entry(janela)
entry_nota.pack()

# Botões
tk.Button(janela, text="Cadastrar", command=cadastrar).pack(pady=5)
tk.Button(janela, text="Atualizar Nota", command=atualizar).pack(pady=5)
tk.Button(janela, text="Deletar", command=deletar).pack(pady=5)

# Tabela simples
tree = ttk.Treeview(janela, columns=("matricula", "nome", "nota"), show="headings")
tree.heading("matricula", text="Matrícula")
tree.heading("nome", text="Nome")
tree.heading("nota", text="Nota")
tree.pack(fill="both", expand=True, pady=10)

# Atualiza automaticamente
atualizar_tabela()

# Iniciar app
janela.mainloop()

# Fecha banco
conn.close()

