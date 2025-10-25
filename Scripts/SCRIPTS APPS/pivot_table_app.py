import tkinter as tk
from tkinter import ttk, messagebox
import pandas as pd
import pyodbc
from sqlalchemy import create_engine
import urllib.parse 


# Hecho con ayuda de la Inteligencia Artificicial 'GEMINI' de Google.

# ==============================================================================
# CONFIGURACIÓN DE LA BASE DE DATOS Y CONEXIÓN
# ==============================================================================

# Nota: SQLAlchemy usará el driver ODBC que ya está instalado en tu sistema.
DRIVER_NAME = 'ODBC Driver 17 for SQL Server'
# Usamos una cadena cruda (raw string) 'r' para el path del servidor
SERVER_NAME = r'DESKTOP-2M9EF79\SQLEXPRESS'
DATABASE_NAME = 'Comportamiento_Online_Jugadores'

# Constantes de la aplicación según los requisitos del usuario

# ------------------------------------------------------------------------------------------

# Jerarquía de filas (ÍNDICE) - ORDEN FIJO
PIVOT_INDEX_FIELDS_FINAL = [
    'Género_de_Juego',       # 1
    'Género',                # 2
    'Dificultad_de_Juego',   # 3
    'Compra_en_Juego',       # 4
    'Nivel_de_Jugador',      # 5
    'Logros_Desbloqueados'   # 6
]

# Campos de filtro fijos
FILTER_FIELDS = [
    'Edad', 
    'Ubicación', 
    'Sesiones_por_Semana', 
    'Duración_de_Sesión_en_Horas_en_Promedio'
]

DEFAULT_VALUE_FIELD = 'ID_de_Jugador' # Columna preferida para el recuento

def get_db_engine():
    """Crea un motor (Engine) de SQLAlchemy para la conexión con la base de datos."""
    try:
        quoted_server = urllib.parse.quote_plus(SERVER_NAME) 
        
        conn_string = (
            f"mssql+pyodbc:///?odbc_connect="
            f"DRIVER={{{DRIVER_NAME}}};"
            f"SERVER={quoted_server};"
            f"DATABASE={DATABASE_NAME};"
            f"Trusted_Connection=yes;"
        )
        
        engine = create_engine(conn_string)          
        
        # Corregir la advertencia de Pandas: usamos .connect() explícitamente.
        with engine.connect():
            return engine   
            
    except Exception as ex:
        messagebox.showerror("Error de Conexión a DB", 
                             f"No se pudo crear el motor de conexión a la base de datos.\n"
                             f"Detalle: {ex}")
        return None

def load_data(engine):
    """Carga los datos en un DataFrame de Pandas usando la conexión de SQLAlchemy."""
    if not engine:
        return None
        
    sql_query = "SELECT * FROM [dbo].[Tabla_Madre]"   
    
    try:
        with engine.connect() as conn:
            df = pd.read_sql(sql_query, conn)
        return df
    except Exception as e:
        messagebox.showerror("Error de Consulta SQL", f"Error al ejecutar la consulta:\n{e}")
        return None

# ==============================================================================
# LÓGICA DE LA APLICACIÓN TKINTER
# ==============================================================================

class PivotApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Tabla Dinámica Personalizada (Recuento)")
        self.geometry("1300x700") 
        
        self.engine = get_db_engine()
        self.df_raw = load_data(self.engine)
        
        if self.df_raw is None:
            self.destroy()
            return
            
        self.all_cols = self.df_raw.columns.tolist()
        
        # VALIDACIÓN CRUCIAL DE COLUMNAS 
        missing_index_cols = [c for c in PIVOT_INDEX_FIELDS_FINAL if c not in self.all_cols]
        missing_filter_cols = [c for c in FILTER_FIELDS if c not in self.all_cols]

        if missing_index_cols or missing_filter_cols:
            error_msg = ("ERROR DE CLAVE (KeyError):\n"
                         "El programa no encuentra las siguientes columnas en tu base de datos.\n"
                         "Por favor, revisa la ortografía exacta (mayúsculas/minúsculas, espacios, guiones):\n")
            
            if missing_index_cols:
                error_msg += f"\nColumnas de FILAS (Índice): {', '.join(missing_index_cols)}"
            if missing_filter_cols:
                error_msg += f"\nColumnas de FILTROS: {', '.join(missing_filter_cols)}"
            
            messagebox.showerror("Error de Coincidencia de Columnas (KeyError)", error_msg)
            self.destroy()
            return
            
        # Determinar el campo de valor para el recuento
        self.value_field = DEFAULT_VALUE_FIELD if DEFAULT_VALUE_FIELD in self.all_cols else self.all_cols[0] 
        
        # Variables de control
        self.filter_vars = {}
        for field in FILTER_FIELDS:
            # Observar cambios en los filtros para actualizar la tabla inmediatamente
            self.filter_vars[field] = tk.StringVar(self, value='(Todos)')
            self.filter_vars[field].trace_add("write", lambda name, index, mode, f=field: self.update_pivot_table())

        self.col_var = tk.StringVar(self, value='') 
        self.col_var.trace_add("write", lambda name, index, mode: self.update_pivot_table())
        
        # Variable para la selección dinámica del índice
        self.selected_index_fields = tk.StringVar(self)
        self.selected_index_fields.trace_add("write", lambda name, index, mode: self.update_pivot_table())

        self.setup_ui()

        # Configuración inicial después de que todos los widgets están listos
        self.index_listbox.select_set(0, tk.END) # Selecciona todos los elementos
        self.handle_index_selection(initial_load=True) # Establece la variable y realiza la primera actualización

    def setup_ui(self):
        """Crea y organiza los widgets de la interfaz. La Treeview se crea primero."""
        
        # 1. Frame para la tabla de resultados (CREADO PRIMERO para evitar el error 'tree')
        table_frame = ttk.Frame(self)
        table_frame.pack(padx=10, pady=5, fill="both", expand=True)

        v_scrollbar = ttk.Scrollbar(table_frame, orient="vertical")
        v_scrollbar.pack(side="right", fill="y")
        
        h_scrollbar = ttk.Scrollbar(table_frame, orient="horizontal")
        h_scrollbar.pack(side="bottom", fill="x")

        # CREACIÓN DE SELF.TREE
        self.tree = ttk.Treeview(table_frame, show='headings', 
                                 yscrollcommand=v_scrollbar.set, 
                                 xscrollcommand=h_scrollbar.set)
        self.tree.pack(fill="both", expand=True)

        v_scrollbar.config(command=self.tree.yview)
        h_scrollbar.config(command=self.tree.xview)

        # 2. Configuración de Controles (CREADO DESPUÉS)
        control_frame = ttk.LabelFrame(self, text="Configuración de la Tabla Dinámica", padding="10 10 10 10")
        control_frame.pack(padx=10, pady=10, fill="x", before=table_frame) # Posicionamiento antes de la tabla
        
        # === FILA 1: Selección Dinámica del Índice (NUEVO) ===
        ttk.Label(control_frame, text="Selección de Jerarquía de Filas:").grid(row=0, column=0, padx=5, pady=5, sticky="w")
        
        self.index_listbox = tk.Listbox(control_frame, selectmode='extended', height=len(PIVOT_INDEX_FIELDS_FINAL), width=30)
        for field in PIVOT_INDEX_FIELDS_FINAL:
            self.index_listbox.insert(tk.END, field)
        
        # La selección real se hace en __init__ después de que todo esté listo
        self.index_listbox.bind('<<ListboxSelect>>', lambda event: self.handle_index_selection())
        self.index_listbox.grid(row=0, column=1, rowspan=2, padx=5, pady=5, sticky="nsew")

        # === FILA 2: Columna y Agregación Fija ===
        
        # Columna dinámica (opcional)
        ttk.Label(control_frame, text="Columna (Agrupación Opcional):").grid(row=1, column=2, padx=5, pady=5, sticky="w")
        self.col_cb = ttk.Combobox(control_frame, textvariable=self.col_var, 
                                   # Solo mostramos columnas que no están ya en el índice fijo
                                   values=[''] + [c for c in self.all_cols if c not in PIVOT_INDEX_FIELDS_FINAL], 
                                   state="readonly")
        self.col_cb.grid(row=1, column=3, padx=5, pady=5, sticky="ew")

        # Valor Fijo (Recuento)
        ttk.Label(control_frame, text="Valor Fijo:").grid(row=0, column=2, padx=5, pady=5, sticky="w")
        ttk.Label(control_frame, text=f"COUNT('{self.value_field}')", foreground="red").grid(row=0, column=3, padx=5, pady=5, sticky="w")
        
        # === FILAS 3, 4: Filtros Específicos ===
        filter_row_start = 2
        
        for i, field in enumerate(FILTER_FIELDS):
            current_row = filter_row_start + (i // 2)
            current_col = 2 + (i % 2) * 2 # Iniciar en la columna 2, usar 2 columnas para cada filtro
            
            # Etiqueta de la columna de filtro
            ttk.Label(control_frame, text=f"Filtro: {field}").grid(row=current_row, column=current_col, padx=5, pady=5, sticky="w")
            
            # Combobox para seleccionar el valor de filtro
            cb = ttk.Combobox(control_frame, textvariable=self.filter_vars[field], 
                              values=['(Todos)'], state="readonly")
            cb.grid(row=current_row, column=current_col + 1, padx=5, pady=5, sticky="ew")
            
            # Guardamos la referencia para el llenado y llenamos los valores
            setattr(self, f"filter_cb_{field.replace(' ', '_').replace('.', '_')}", cb)
            self.update_filter_values(field)

        control_frame.grid_columnconfigure(1, weight=1)
        control_frame.grid_columnconfigure(3, weight=1)


    def handle_index_selection(self, initial_load=False):
        """Traduce la selección del Listbox a una lista ordenada de campos de índice."""
        selected_indices = self.index_listbox.curselection()
        current_index_fields = [PIVOT_INDEX_FIELDS_FINAL[i] for i in selected_indices]
        
        # Guarda la lista de campos seleccionados como una cadena serializada
        self.selected_index_fields.set("|".join(current_index_fields))
        
        # Si es la carga inicial, el update_pivot_table se llamará una vez al final de __init__.
        # Si no, se llama a través del trace_add de selected_index_fields.
        
    def update_filter_values(self, column_name):
        """Actualiza los valores posibles para el Combobox de un filtro específico."""
        try:
            # Reemplazamos espacios y puntos por guiones bajos para obtener el nombre del atributo dinámico
            cb = getattr(self, f"filter_cb_{column_name.replace(' ', '_').replace('.', '_')}")
            val_var = self.filter_vars[column_name]
            
            unique_values = ['(Todos)'] + sorted(self.df_raw[column_name].dropna().astype(str).unique().tolist())
            
            cb['values'] = unique_values
            
            if val_var.get() not in unique_values:
                val_var.set('(Todos)')
        except Exception as e:
            # Esto solo debería ocurrir si load_data falló o si hay un error de lógica interna.
            print(f"Error al actualizar valores de filtro para {column_name}: {e}")
        
    def update_pivot_table(self):
        """Realiza el filtrado, el pivoteo con Pandas y actualiza el Treeview."""
        # Se asegura de que self.tree esté listo (prevención contra errores de temporización)
        if not hasattr(self, 'tree'):
            return

        try:
            # Obtener campos de índice seleccionados y la columna opcional
            col_field = self.col_var.get()
            index_fields_str = self.selected_index_fields.get()
            index_fields = index_fields_str.split("|") if index_fields_str else None
            
            # 1. Aplicar Filtros al DataFrame original
            df_filtered = self.df_raw.copy()
            
            for field in FILTER_FIELDS:
                filter_val = self.filter_vars[field].get()
                if filter_val != '(Todos)':
                    df_filtered = df_filtered[df_filtered[field].astype(str) == filter_val]

            if df_filtered.empty or not index_fields:
                self.tree.delete(*self.tree.get_children())
                # Mostrar mensaje si no hay datos o no se seleccionó índice
                msg = "No hay datos para los filtros seleccionados." if df_filtered.empty else "Selecciona al menos un campo para el índice."
                self.tree["columns"] = ["Mensaje"]
                self.tree.heading("Mensaje", text="Mensaje")
                self.tree.column("Mensaje", anchor=tk.CENTER, width=300)
                self.tree.insert("", tk.END, values=[msg])
                return

            # 2. Generar la Tabla Dinámica con Pandas
            df_pivot = pd.pivot_table(
                df_filtered, 
                index=index_fields, # Jerarquía DINÁMICA
                columns=col_field if col_field else None, # Opcional
                values=self.value_field, # Fijo para el recuento
                aggfunc='count', # Fijo
                fill_value=0
            )

            # 3. Limpiar Treeview anterior y configurar columnas
            self.tree.delete(*self.tree.get_children())
            df_pivot = df_pivot.reset_index()
            tree_cols = df_pivot.columns.tolist()
            
            self.tree["columns"] = tree_cols
            
            # Configurar las columnas de índice
            for col in index_fields:
                 self.tree.column(col, anchor=tk.W, width=150)
                 self.tree.heading(col, text=col)
                 
            # Configurar la columna opcional y las columnas de valores
            value_cols = [col for col in tree_cols if col not in index_fields]
            
            for col in value_cols:
                self.tree.column(col, anchor=tk.E, width=120)
                if col == col_field:
                     self.tree.heading(col, text=col) 
                else:
                     self.tree.heading(col, text="Recuento") 

            # 4. Insertar Datos y calcular Total General
            total_general = 0
            
            for index, row in df_pivot.iterrows():
                current_values = []
                row_total = 0
                
                for i, v in enumerate(row.tolist()):
                    is_value_column = i >= len(index_fields)
                    
                    if is_value_column and isinstance(v, (int, float)):
                         count_val = int(v)
                         current_values.append(str(count_val))
                         row_total += count_val
                    else:
                        current_values.append(str(v))
                        
                self.tree.insert("", tk.END, values=current_values)
                total_general += row_total
                
            # 5. Insertar la Fila del Total General
            if total_general > 0:
                # Estilos para la fila de total (negrita y color)
                self.tree.tag_configure('total', background='#E0E0E0', font=('TkDefaultFont', 10, 'bold'))

                # Crear la lista de valores para la fila de total
                # Rellena las columnas de índice con cadenas vacías excepto la primera
                total_row_values = ["Total General"] + [""] * (len(index_fields) - 1)
                
                if not col_field:
                    # Si no hay columna opcional, el total es un solo valor (el recuento total)
                    total_row_values.append(str(int(total_general))) 
                else:
                    # Si hay columna opcional, debemos sumar los valores por columna
                    # Sumamos todas las columnas a partir de la primera columna de valor
                    col_totals = df_pivot.iloc[:, len(index_fields):].sum(axis=0)
                    total_row_values.extend([str(int(t)) for t in col_totals.tolist()])

                # Insertar la fila
                self.tree.insert("", tk.END, values=total_row_values, tags=('total',))
                
        except Exception as e:
            # Captura cualquier error de pivoteo que pueda ocurrir
            messagebox.showerror("Error de Pivoteo", f"Ocurrió un error en la generación de la tabla:\n{e}")

# ==============================================================================
# EJECUCIÓN
# ==============================================================================
if __name__ == "__main__":
    app = PivotApp()
    if app.df_raw is not None:
        app.mainloop()