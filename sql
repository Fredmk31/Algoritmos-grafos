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
def calcular_situacao(nota):
    return "Aprovado" if nota >= 6 else "Reprovado"

def cadastrar():
    m, n, nota = entry_matricula.get(), entry_nome.get(), entry_nota.get()
    if not (m and n and nota):
        messagebox.showwarning("Atenção", "Preencha todos os campos!")
        return
    try:
        cursor.execute("INSERT INTO alunos VALUES (?, ?, ?)", (m, n, float(nota)))
        conn.commit()
        messagebox.showinfo("Sucesso", "Aluno cadastrado!")
        limpar_campos()
        atualizar_tabela()
    except sqlite3.IntegrityError:
        messagebox.showerror("Erro", "Matrícula já cadastrada.")
    except ValueError:
        messagebox.showerror("Erro", "Nota inválida.")

def atualizar():
    m, nova_nota = entry_matricula.get(), entry_nota.get()
    if not (m and nova_nota):
        messagebox.showwarning("Atenção", "Preencha matrícula e nova nota.")
        return
    try:
        cursor.execute("UPDATE alunos SET nota = ? WHERE matricula = ?", (float(nova_nota), m))
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
    for i, (m, n, nota) in enumerate(cursor.fetchall()):
        situacao = calcular_situacao(nota)
        tree.insert("", "end", values=(m, n, nota, situacao), tags=("oddrow" if i % 2 else "evenrow"))
    tree.tag_configure("oddrow", background="#E8E8E8")
    tree.tag_configure("evenrow", background="#FFFFFF")

# Estilização da janela
janela = tk.Tk()
janela.title("Cadastro de Alunos - Situação")
janela.geometry("650x500")
janela.configure(bg="#f5f5f5")

# Configuração de estilos
style = ttk.Style()
style.configure("Treeview", font=("Raleway", 12), rowheight=25)
style.configure("Treeview.Heading", font=("Montserrat", 14, "bold"))
style.configure("TButton", font=("Raleway", 12), background="#4CAF50", padding=6)

# Criar um frame estilizado
frame = tk.Frame(janela, bg="#ffffff", padx=10, pady=10, relief="solid", bd=2)
frame.pack(pady=10, fill="both")

tk.Label(frame, text="Matrícula:", font=("Raleway", 12)).grid(row=0, column=0, sticky="w", padx=5)
entry_matricula = tk.Entry(frame, font=("Raleway", 12))
entry_matricula.grid(row=0, column=1)

tk.Label(frame, text="Nome:", font=("Raleway", 12)).grid(row=1, column=0, sticky="w", padx=5)
entry_nome = tk.Entry(frame, font=("Raleway", 12))
entry_nome.grid(row=1, column=1)

tk.Label(frame, text="Nota:", font=("Raleway", 12)).grid(row=2, column=0, sticky="w", padx=5)
entry_nota = tk.Entry(frame, font=("Raleway", 12))
entry_nota.grid(row=2, column=1)

# Botões estilizados
btn_frame = tk.Frame(janela, bg="#f5f5f5")
btn_frame.pack(pady=5, fill="x")

def hover(event, btn, color):
    btn.config(bg=color)

btn_cadastrar = tk.Button(btn_frame, text="Cadastrar", font=("Raleway", 12), bg="#4CAF50", fg="white", relief="flat", command=cadastrar)
btn_cadastrar.pack(side="left", padx=5)
btn_cadastrar.bind("<Enter>", lambda e: hover(e, btn_cadastrar, "#45A049"))
btn_cadastrar.bind("<Leave>", lambda e: hover(e, btn_cadastrar, "#4CAF50"))

btn_atualizar = tk.Button(btn_frame, text="Atualizar Nota", font=("Raleway", 12), bg="#FFC107", fg="black", relief="flat", command=atualizar)
btn_atualizar.pack(side="left", padx=5)
btn_atualizar.bind("<Enter>", lambda e: hover(e, btn_atualizar, "#E0A800"))
btn_atualizar.bind("<Leave>", lambda e: hover(e, btn_atualizar, "#FFC107"))

btn_deletar = tk.Button(btn_frame, text="Deletar", font=("Raleway", 12), bg="#F44336", fg="white", relief="flat", command=deletar)
btn_deletar.pack(side="left", padx=5)
btn_deletar.bind("<Enter>", lambda e: hover(e, btn_deletar, "#D32F2F"))
btn_deletar.bind("<Leave>", lambda e: hover(e, btn_deletar, "#F44336"))

# Tabela estilizada
tree_frame = tk.Frame(janela)
tree_frame.pack(fill="both", expand=True, pady=10)

tree = ttk.Treeview(tree_frame, columns=("matricula", "nome", "nota", "situacao"), show="headings", height=8)
tree.heading("matricula", text="Matrícula", anchor="center")
tree.heading("nome", text="Nome", anchor="center")
tree.heading("nota", text="Nota", anchor="center")
tree.heading("situacao", text="Situação", anchor="center")

tree.pack(fill="both", expand=True, pady=5)

# Atualiza tabela ao iniciar
atualizar_tabela()

# Iniciar aplicativo
janela.mainloop()

# Fecha banco
conn.close()
