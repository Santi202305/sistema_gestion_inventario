#!/usr/bin/env python3
"""
Generador del documento formal PDF_Evidencias.pdf bajo normas APA 7ma edición.
Sistema de Gestión de Inventario — API REST + Flutter
Electiva Profesional I
"""

import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, KeepTogether
)
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY

def build_pdf(filename="entregables/PDF_Evidencias.pdf"):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    
    # Dimensiones estándar carta: 8.5 x 11 pulgadas
    # Márgenes APA 7: 1 pulgada (72 pt) en los cuatro costados
    margin = 72
    printable_width = letter[0] - 2 * margin # 468 pt
    printable_height = letter[1] - 2 * margin # 648 pt

    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=margin,
        rightMargin=margin,
        topMargin=margin,
        bottomMargin=margin
    )

    styles = getSampleStyleSheet()

    # Tipografía y Jerarquía APA 7ma Edición (Texto estricto en negro)
    title_cover_style = ParagraphStyle(
        'CoverTitle',
        fontName='Times-Bold',
        fontSize=15,
        leading=22,
        alignment=TA_CENTER,
        textColor=colors.black,
        spaceAfter=14
    )

    subtitle_cover_style = ParagraphStyle(
        'CoverSubtitle',
        fontName='Times-Roman',
        fontSize=12,
        leading=18,
        alignment=TA_CENTER,
        textColor=colors.black,
        spaceAfter=24
    )

    meta_cover_style = ParagraphStyle(
        'CoverMeta',
        fontName='Times-Roman',
        fontSize=11,
        leading=20,
        alignment=TA_CENTER,
        textColor=colors.black
    )

    h1_style = ParagraphStyle(
        'APA_H1',
        fontName='Times-Bold',
        fontSize=13,
        leading=17,
        alignment=TA_CENTER,
        textColor=colors.black,
        spaceBefore=10,
        spaceAfter=8,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'APA_H2',
        fontName='Times-Bold',
        fontSize=11.5,
        leading=15,
        alignment=TA_LEFT,
        textColor=colors.black,
        spaceBefore=8,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'APA_Body',
        fontName='Times-Roman',
        fontSize=10.5,
        leading=15,
        alignment=TA_LEFT,
        firstLineIndent=36, # Sangría APA 0.5 in
        textColor=colors.black,
        spaceAfter=6
    )

    bullet_style = ParagraphStyle(
        'APA_Bullet',
        fontName='Times-Roman',
        fontSize=10,
        leading=14,
        alignment=TA_LEFT,
        leftIndent=24,
        textColor=colors.black,
        spaceAfter=4
    )

    fig_intro_style = ParagraphStyle(
        'FigIntro',
        fontName='Times-Roman',
        fontSize=10.5,
        leading=15,
        alignment=TA_LEFT,
        firstLineIndent=36,
        textColor=colors.black,
        spaceAfter=8,
        keepWithNext=True
    )

    fig_label_style = ParagraphStyle(
        'FigLabel',
        fontName='Times-Bold',
        fontSize=10,
        leading=13,
        alignment=TA_LEFT,
        textColor=colors.black,
        spaceAfter=2,
        keepWithNext=True
    )

    fig_title_style = ParagraphStyle(
        'FigTitle',
        fontName='Times-Italic',
        fontSize=10,
        leading=13,
        alignment=TA_LEFT,
        textColor=colors.black,
        spaceAfter=6,
        keepWithNext=True
    )

    fig_note_style = ParagraphStyle(
        'FigNote',
        fontName='Times-Roman',
        fontSize=9,
        leading=13,
        alignment=TA_LEFT,
        textColor=colors.black,
        spaceBefore=4,
        spaceAfter=6
    )

    code_style = ParagraphStyle(
        'CodeStyle',
        fontName='Courier',
        fontSize=7.5,
        leading=10,
        textColor=colors.black
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Times-Bold',
        fontSize=9,
        leading=12,
        alignment=TA_CENTER,
        textColor=colors.black
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        fontName='Times-Roman',
        fontSize=8.5,
        leading=11,
        alignment=TA_LEFT,
        textColor=colors.black
    )

    story = []

    # =========================================================================
    # 1. PORTADA FORMAL (APA 7 ESTUDIANTIL)
    # =========================================================================
    story.append(Spacer(1, 50))
    story.append(Paragraph("Sistema de Gestión de Inventario — API REST + Flutter", title_cover_style))
    story.append(Paragraph("Diseño e Implementación de un Sistema de Inventario con Arquitectura Desacoplada, Persistencia Relacional y Cliente Móvil Reactivo", subtitle_cover_style))
    
    story.append(Spacer(1, 110))
    story.append(Paragraph("<b>Autor:</b> [NOMBRE COMPLETO]<br/>"
                           "<b>Código Estudiantil:</b> [CÓDIGO]<br/>"
                           "<b>Programa Académico:</b> [PROGRAMA ACADÉMICO]<br/>"
                           "<b>Institución:</b> Facultad de Ingeniería, [INSTITUCIÓN]<br/>"
                           "<b>Asignatura:</b> Electiva Profesional I<br/>"
                           "<b>Docente:</b> [NOMBRE DEL DOCENTE]<br/>"
                           "<b>Fecha:</b> Octubre de 2026", meta_cover_style))
    story.append(PageBreak())

    # =========================================================================
    # 2. ENLACES Y ARQUITECTURA GENERAL
    # =========================================================================
    story.append(Paragraph("Enlaces del Proyecto", h1_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph(
        "En cumplimiento de los requerimientos de la asignatura, se relacionan los accesos directos "
        "al repositorio de código fuente versionado y al registro audiovisual demostrativo:",
        body_style
    ))

    links_data = [
        [
            Paragraph("<b>Recurso</b>", table_header_style),
            Paragraph("<b>Ubicación / Enlace</b>", table_header_style),
            Paragraph("<b>Alcance del Contenido</b>", table_header_style)
        ],
        [
            Paragraph("<b>Repositorio GitHub</b>", table_cell_style),
            Paragraph("<u>https://github.com/Santi202305/sistema_gestion_inventario.git</u>", table_cell_style),
            Paragraph("Código fuente estructurado del backend (Node.js/Express) y frontend (Flutter), documentación en README.md, scripts y pruebas de integración.", table_cell_style)
        ],
        [
            Paragraph("<b>Video de Sustentación</b>", table_cell_style),
            Paragraph("<b>[ENLACE AL VIDEO DE SUSTENTACIÓN — PEGAR AQUÍ]</b>", table_cell_style),
            Paragraph("Demostración audiovisual de los 5 endpoints mediante Thunder Client / REST Client (códigos 200, 201, 404, 422) y recorrido completo de la app Flutter sobre emulador Android.", table_cell_style)
        ]
    ]

    t_links = Table(links_data, colWidths=[90, 188, 190])
    t_links.setStyle(TableStyle([
        ('LINEABOVE', (0, 0), (-1, 0), 1.0, colors.black),
        ('LINEBELOW', (0, 0), (-1, 0), 0.75, colors.black),
        ('LINEBELOW', (0, -1), (-1, -1), 1.0, colors.black),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(t_links)
    story.append(Spacer(1, 10))

    story.append(Paragraph("Descripción Técnica del Sistema", h1_style))
    story.append(Paragraph("Arquitectura General", h2_style))
    story.append(Paragraph(
        "El sistema adopta una arquitectura desacoplada basada en servicios REST y codificación JSON a través de HTTP. "
        "El backend expone servicios sin estado consumidos directamente por la aplicación Flutter. No se utilizan listas estáticas, "
        "datos simulados ni almacenamiento volátil; cada acción de consulta o mutación interactúa directamente con una base de datos SQLite real.",
        body_style
    ))

    story.append(Paragraph("Componentes y Tecnologías Seleccionadas", h2_style))
    story.append(Paragraph("• <b>Backend:</b> Node.js (v20+) con framework web Express (v4.22.1). Enrutamiento modular, validadores desacoplados, registro de peticiones (logging) y habilitación de CORS.", bullet_style))
    story.append(Paragraph("• <b>Base de Datos:</b> SQLite relacional mediante el módulo nativo de alto rendimiento <code>better-sqlite3</code>, configurada con modo WAL (Write-Ahead Logging) y almacenamiento persistente en disco (<code>backend/data/inventario.sqlite</code>).", bullet_style))
    story.append(Paragraph("• <b>Frontend:</b> Framework Flutter (v3.29+) con lenguaje Dart (v3.7+). Cliente HTTP robusto con <code>dio</code> (control de timeouts y cabeceras), navegación declarativa basada en rutas con nombre mediante <code>go_router</code>, y gestión de variables mediante <code>flutter_dotenv</code>.", bullet_style))
    story.append(Paragraph("• <b>Gestión de Estado:</b> Reactividad desacoplada implementada a través de la clase <code>ChangeNotifier</code> y constructores <code>ListenableBuilder</code> sin librerías externas pesadas, asegurando cálculo automático de métricas en el Dashboard.", bullet_style))
    story.append(PageBreak())

    # =========================================================================
    # 3. MODELO DE DATOS Y ENDPOINTS
    # =========================================================================
    story.append(Paragraph("Modelo de Datos y Especificación de la API", h1_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("Entidad Relacional de Productos", h2_style))
    story.append(Paragraph(
        "La base de datos almacena la entidad <code>productos</code> con siete atributos, incorporando restricciones "
        "estrictas de dominio y unicidad tanto a nivel de motor SQL como en la capa de validación de la aplicación:",
        body_style
    ))

    schema_data = [
        [
            Paragraph("<b>Campo</b>", table_header_style),
            Paragraph("<b>Tipo SQLite</b>", table_header_style),
            Paragraph("<b>Nulidad</b>", table_header_style),
            Paragraph("<b>Restricción / Regla de Negocio</b>", table_header_style)
        ],
        [
            Paragraph("id", table_cell_style),
            Paragraph("INTEGER", table_cell_style),
            Paragraph("NOT NULL", table_cell_style),
            Paragraph("Llave primaria autoincremental única.", table_cell_style)
        ],
        [
            Paragraph("nombre", table_cell_style),
            Paragraph("TEXT", table_cell_style),
            Paragraph("NOT NULL", table_cell_style),
            Paragraph("Nombre comercial obligatorio, normalizado sin espacios vacíos.", table_cell_style)
        ],
        [
            Paragraph("codigo", table_cell_style),
            Paragraph("TEXT", table_cell_style),
            Paragraph("NOT NULL", table_cell_style),
            Paragraph("Identificador alfanumérico único. Índice UNIQUE en base de datos.", table_cell_style)
        ],
        [
            Paragraph("descripcion", table_cell_style),
            Paragraph("TEXT", table_cell_style),
            Paragraph("NULL", table_cell_style),
            Paragraph("Detalle técnico descriptivo opcional (permite valor nulo).", table_cell_style)
        ],
        [
            Paragraph("precio", table_cell_style),
            Paragraph("REAL", table_cell_style),
            Paragraph("NOT NULL", table_cell_style),
            Paragraph("Valor monetario en COP; numérico estrictamente mayor a 0.", table_cell_style)
        ],
        [
            Paragraph("cantidad", table_cell_style),
            Paragraph("INTEGER", table_cell_style),
            Paragraph("NOT NULL", table_cell_style),
            Paragraph("Stock físico; valor entero mayor o igual a 0.", table_cell_style)
        ],
        [
            Paragraph("categoria", table_cell_style),
            Paragraph("TEXT", table_cell_style),
            Paragraph("NOT NULL", table_cell_style),
            Paragraph("Clasificación temática de inventario obligatoria.", table_cell_style)
        ]
    ]

    t_schema = Table(schema_data, colWidths=[60, 75, 75, 258])
    t_schema.setStyle(TableStyle([
        ('LINEABOVE', (0, 0), (-1, 0), 1.0, colors.black),
        ('LINEBELOW', (0, 0), (-1, 0), 0.75, colors.black),
        ('LINEBELOW', (0, -1), (-1, -1), 1.0, colors.black),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
    ]))
    story.append(t_schema)
    story.append(Spacer(1, 8))

    story.append(Paragraph("Especificación de Endpoints REST (Prefijo /api)", h2_style))
    story.append(Paragraph(
        "La interfaz del servidor expone cinco operaciones HTTP diseñadas conforme al contrato estandarizado de la aplicación:",
        body_style
    ))

    endpoints_data = [
        [
            Paragraph("<b>Método</b>", table_header_style),
            Paragraph("<b>Ruta</b>", table_header_style),
            Paragraph("<b>Descripción del Servicio</b>", table_header_style),
            Paragraph("<b>Respuestas HTTP</b>", table_header_style)
        ],
        [
            Paragraph("GET", table_cell_style),
            Paragraph("/api/productos", table_cell_style),
            Paragraph("Retorna el arreglo completo de productos registrados.", table_cell_style),
            Paragraph("200 OK<br/>500 Internal Error", table_cell_style)
        ],
        [
            Paragraph("GET", table_cell_style),
            Paragraph("/api/productos/:id", table_cell_style),
            Paragraph("Obtiene el registro individual del producto por identificador.", table_cell_style),
            Paragraph("200 OK<br/>404 Not Found", table_cell_style)
        ],
        [
            Paragraph("POST", table_cell_style),
            Paragraph("/api/productos", table_cell_style),
            Paragraph("Valida e inserta un nuevo registro de producto en la base de datos.", table_cell_style),
            Paragraph("201 Created<br/>422 Unprocessable", table_cell_style)
        ],
        [
            Paragraph("PUT", table_cell_style),
            Paragraph("/api/productos/:id", table_cell_style),
            Paragraph("Actualiza de forma integral los atributos de un producto existente.", table_cell_style),
            Paragraph("200 OK<br/>404 Not Found<br/>422 Unprocessable", table_cell_style)
        ],
        [
            Paragraph("DELETE", table_cell_style),
            Paragraph("/api/productos/:id", table_cell_style),
            Paragraph("Elimina físicamente el producto seleccionado de la base de datos.", table_cell_style),
            Paragraph("200 OK<br/>404 Not Found", table_cell_style)
        ]
    ]

    t_endpoints = Table(endpoints_data, colWidths=[50, 115, 195, 108])
    t_endpoints.setStyle(TableStyle([
        ('LINEABOVE', (0, 0), (-1, 0), 1.0, colors.black),
        ('LINEBELOW', (0, 0), (-1, 0), 0.75, colors.black),
        ('LINEBELOW', (0, -1), (-1, -1), 1.0, colors.black),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
    ]))
    story.append(t_endpoints)
    story.append(PageBreak())

    # =========================================================================
    # 4. EVIDENCIAS DEL BACKEND (API REST)
    # =========================================================================
    story.append(Paragraph("Evidencias del Funcionamiento del Backend", h1_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph(
        "Se ejecutó una batería integral de pruebas de integración con peticiones HTTP reales sobre el servidor Express en puerto 3000. "
        "A continuación se documentan las salidas exactas de consola:",
        body_style
    ))

    story.append(Paragraph("Pruebas de los 5 Endpoints Obligatorios", h2_style))

    sample_crud_text = (
        "1. LISTAR PRODUCTOS (GET /api/productos):\n"
        "HTTP/1.1 200 OK | Content-Type: application/json\n"
        "[{\"id\":1,\"nombre\":\"Mouse Inalámbrico Ergonómico\",\"codigo\":\"TEC-001\","
        "\"precio\":45000,\"cantidad\":25,\"categoria\":\"Tecnología\"}, ...]\n\n"
        "2. CONSULTAR POR ID (GET /api/productos/1):\n"
        "HTTP/1.1 200 OK -> {\"id\":1,\"nombre\":\"Mouse Inalámbrico Ergonómico\",\"codigo\":\"TEC-001\",\"precio\":45000,\"cantidad\":25}\n\n"
        "3. REGISTRAR PRODUCTO (POST /api/productos):\n"
        "Payload: {\"nombre\":\"Micrófono Condensador USB\",\"codigo\":\"MIC-001\",\"precio\":135000.0,\"cantidad\":12,\"categoria\":\"Audio\"}\n"
        "HTTP/1.1 201 Created -> {\"id\":25,\"nombre\":\"Micrófono Condensador USB\",\"codigo\":\"MIC-001\",\"precio\":135000,\"cantidad\":12}\n\n"
        "4. ACTUALIZAR PRODUCTO (PUT /api/productos/25):\n"
        "Payload: {\"nombre\":\"Micrófono USB Pro Editado\",\"codigo\":\"MIC-001\",\"precio\":149900.0,\"cantidad\":10,\"categoria\":\"Audio\"}\n"
        "HTTP/1.1 200 OK -> {\"id\":25,\"nombre\":\"Micrófono USB Pro Editado\",\"codigo\":\"MIC-001\",\"precio\":149900,\"cantidad\":10}\n\n"
        "5. ELIMINAR PRODUCTO (DELETE /api/productos/25):\n"
        "HTTP/1.1 200 OK -> {\"message\":\"Producto eliminado correctamente\"}"
    )

    t_box1 = Table([[Paragraph(f"<pre>{sample_crud_text}</pre>", code_style)]], colWidths=[printable_width])
    t_box1.setStyle(TableStyle([
        ('BOX', (0, 0), (-1, -1), 0.5, colors.gray),
        ('BACKGROUND', (0, 0), (-1, -1), colors.whitesmoke),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_box1)
    story.append(Spacer(1, 6))

    story.append(Paragraph("Manejo de Errores: Validación 422 y Recurso Inexistente 404", h2_style))

    errors_text = (
        "A. RECURSO INEXISTENTE (404 Not Found):\n"
        "GET /api/productos/9999 -> HTTP/1.1 404 Not Found -> {\"message\":\"Producto no encontrado\"}\n\n"
        "B. CAMPOS OBLIGATORIOS FALTANTES O VACIOS (422 Unprocessable Entity):\n"
        "POST /api/productos | Payload: {\"nombre\":\"\",\"codigo\":\"\",\"precio\":null,\"cantidad\":null,\"categoria\":\"\"}\n"
        "HTTP/1.1 422 Unprocessable Entity\n"
        "{\n"
        "  \"message\": \"Datos inválidos\",\n"
        "  \"errors\": {\n"
        "    \"nombre\": [\"El nombre es obligatorio\"],\n"
        "    \"codigo\": [\"El código es obligatorio\"],\n"
        "    \"precio\": [\"El precio es obligatorio\"],\n"
        "    \"cantidad\": [\"La cantidad es obligatoria\"],\n"
        "    \"categoria\": [\"La categoría es obligatoria\"]\n"
        "  }\n"
        "}\n\n"
        "C. PRECIO NEGATIVO Y CANTIDAD DECIMAL (422 Unprocessable Entity):\n"
        "POST /api/productos | Payload: {\"nombre\":\"X\",\"codigo\":\"INV-01\",\"precio\":-500,\"cantidad\":3.5,\"categoria\":\"Test\"}\n"
        "HTTP/1.1 422 Unprocessable Entity\n"
        "{\n"
        "  \"message\": \"Datos inválidos\",\n"
        "  \"errors\": {\n"
        "    \"precio\": [\"El precio debe ser un número mayor a 0\"],\n"
        "    \"cantidad\": [\"La cantidad debe ser un número entero mayor o igual a 0\"]\n"
        "  }\n"
        "}\n\n"
        "D. CODIGO DUPLICADO EN REGISTRO (422 Unprocessable Entity):\n"
        "POST /api/productos | Payload: {\"codigo\":\"TEC-001\", ...}\n"
        "HTTP/1.1 422 Unprocessable Entity -> {\"message\":\"Datos inválidos\",\"errors\":{\"codigo\":[\"El código ya está registrado por otro producto\"]}}"
    )

    t_box2 = Table([[Paragraph(f"<pre>{errors_text}</pre>", code_style)]], colWidths=[printable_width])
    t_box2.setStyle(TableStyle([
        ('BOX', (0, 0), (-1, -1), 0.5, colors.gray),
        ('BACKGROUND', (0, 0), (-1, -1), colors.whitesmoke),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_box2)
    story.append(PageBreak())

    # =========================================================================
    # 5. PERSISTENCIA, DESPLIEGUE Y CONCLUSIONES
    # =========================================================================
    story.append(Paragraph("Persistencia, Despliegue y Consideraciones Finales", h1_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("Evidencia de Persistencia Real en Base de Datos SQLite", h2_style))
    story.append(Paragraph(
        "Para validar la persistencia estricta en el almacenamiento físico, se verificó el recuento de registros "
        "y la sumatoria económica antes y después de reiniciar el servicio Express:",
        body_style
    ))

    persistence_text = (
        "CONSULTA PREVIA AL REINICIO DEL PROCESO:\n"
        "sqlite3 backend/data/inventario.sqlite \"SELECT COUNT(*) FROM productos;\" -> 12 productos\n"
        "sqlite3 backend/data/inventario.sqlite \"SELECT SUM(cantidad), SUM(precio*cantidad) FROM productos;\" -> 346 unidades | $14,976,500 COP\n\n"
        "REINICIO COMPLETO DEL SERVIDOR:\n"
        "kill $(pgrep -f 'node src/app.js') && sleep 2 && PORT=3000 node src/app.js &\n\n"
        "CONSULTA POSTERIOR AL REINICIO:\n"
        "sqlite3 backend/data/inventario.sqlite \"SELECT COUNT(*) FROM productos;\" -> 12 productos (Integridad 100% verificada)\n"
        "sqlite3 backend/data/inventario.sqlite \"SELECT SUM(cantidad), SUM(precio*cantidad) FROM productos;\" -> 346 unidades | $14,976,500 COP (Idéntico)"
    )

    t_box3 = Table([[Paragraph(f"<pre>{persistence_text}</pre>", code_style)]], colWidths=[printable_width])
    t_box3.setStyle(TableStyle([
        ('BOX', (0, 0), (-1, -1), 0.5, colors.gray),
        ('BACKGROUND', (0, 0), (-1, -1), colors.whitesmoke),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_box3)
    story.append(Spacer(1, 8))

    story.append(Paragraph("Despliegue de la Aplicación", h2_style))
    story.append(Paragraph(
        "<b>No aplica (desarrollo local)</b>. De acuerdo con las instrucciones del proyecto, el despliegue en nube es opcional "
        "y no ha sido implementado. La solución está completamente configurada para ejecución local verificada: el backend escucha "
        "en <code>0.0.0.0:3000</code> permitiendo la conexión de emuladores Android (<code>http://10.0.2.2:3000/api</code>) y dispositivos físicos.",
        body_style
    ))
    story.append(Spacer(1, 6))

    story.append(Paragraph("Conclusiones", h2_style))
    story.append(Paragraph("1. La arquitectura desacoplada REST/JSON garantiza una clara separación de responsabilidades y modularidad completa entre cliente móvil y servidor.", bullet_style))
    story.append(Paragraph("2. La persistencia en SQLite con <code>better-sqlite3</code> en modo WAL provee alta concurrencia y tolerancia a fallos en entorno de almacenamiento local.", bullet_style))
    story.append(Paragraph("3. La reactividad nativa con <code>ChangeNotifier</code> asegura que mutaciones en el inventario actualicen instantáneamente los indicadores sin recargas globales.", bullet_style))
    story.append(Paragraph("4. La respuesta 422 con granularidad de errores por campo proporciona al usuario retroalimentación contextual directa en cada elemento del formulario.", bullet_style))
    story.append(PageBreak())

    # =========================================================================
    # 6. EVIDENCIAS DEL FRONTEND (14 FIGURAS APA 7)
    # =========================================================================
    figures_def = [
        {
            "num": 1,
            "img": "docs/screenshots/01-dashboard.png",
            "title": "Dashboard Principal con Métricas Consolidadas del Inventario",
            "text": "La pantalla inicial del sistema se documenta en la Figura 1, presentando la identidad corporativa y las tarjetas con métricas agregadas en tiempo real:",
            "note": "El Dashboard calcula en tiempo real el total de productos registrados (12), las existencias en stock (346 unidades) y la valoración económica ($ 14.976.500 COP) consumiendo la API REST."
        },
        {
            "num": 2,
            "img": "docs/screenshots/02-lista-productos.png",
            "title": "Catálogo Completo y Listado de Productos Registrados",
            "text": "En la Figura 2 se observa el catálogo general de inventario, implementado mediante un ListView reactivo con tarjetas individuales y acceso al detalle:",
            "note": "Cada ítem de la lista expone el nombre comercial del artículo, código único, categoría, precio en moneda colombiana y disponibilidad actual en stock."
        },
        {
            "num": 3,
            "img": "docs/screenshots/03-detalle-producto.png",
            "title": "Vista de Detalle Completo de un Producto Seleccionado",
            "text": "Al pulsar sobre un elemento del catálogo, la aplicación navega a la pantalla de detalle ilustrada en la Figura 3:",
            "note": "Esta vista recupera los datos individuales desde GET /api/productos/:id, ofreciendo acciones directas para actualizar datos o eliminar el registro."
        },
        {
            "num": 4,
            "img": "docs/screenshots/04-formulario-registro.png",
            "title": "Formulario para el Registro de un Nuevo Producto",
            "text": "La interfaz para captura de nuevos artículos se detalla en la Figura 4:",
            "note": "Formulario estructurado con validación local y tipos de teclado optimizados según la naturaleza del dato (numérico para precio y cantidad)."
        },
        {
            "num": 5,
            "img": "docs/screenshots/05-formulario-errores-validacion.png",
            "title": "Formulario con Retroalimentación Visual de Errores de Validación (422)",
            "text": "Cuando los datos ingresados son rechazados por la API, el formulario refleja los errores contextuales como se exhibe en la Figura 5:",
            "note": "El cliente mapea el mapa de errores HTTP 422 directamente a los controles visuales, indicando campos obligatorios, valores negativos o códigos duplicados."
        },
        {
            "num": 6,
            "img": "docs/screenshots/06-producto-creado.png",
            "title": "Notificación Emergente (SnackBar) tras Creación Exitosa de un Producto",
            "text": "Al procesar exitosamente la petición POST, el sistema despliega una notificación flotante, tal como se aprecia en la Figura 6:",
            "note": "SnackBar flotante con fondo verde que confirma al usuario la creación del registro y retorno al catálogo con la lista actualizada."
        },
        {
            "num": 7,
            "img": "docs/screenshots/07-formulario-edicion.png",
            "title": "Formulario de Edición con Datos Precargados del Producto",
            "text": "Para modificar un artículo existente se utiliza el formulario reutilizable en modo edición, exhibido en la Figura 7:",
            "note": "Los campos se inicializan con la información recuperada de la API mediante la ruta /productos/:id/editar, ejecutando una petición PUT al enviar."
        },
        {
            "num": 8,
            "img": "docs/screenshots/08-producto-editado.png",
            "title": "Confirmación Visual tras la Actualización Exitosa de un Producto",
            "text": "La confirmación de la actualización en el servidor se presenta en la Figura 8:",
            "note": "Notificación SnackBar que certifica la persistencia de los cambios y la sincronización inmediata del estado general del inventario."
        },
        {
            "num": 9,
            "img": "docs/screenshots/09-confirmacion-eliminar.png",
            "title": "Diálogo Modal de Confirmación para la Eliminación de un Producto",
            "text": "Como mecanismo de salvaguarda ante eliminaciones accidentales, la app despliega el diálogo ilustrado en la Figura 9:",
            "note": "Diálogo modal AlertDialog que requiere aprobación explícita antes de enviar la petición DELETE /api/productos/:id al servidor."
        },
        {
            "num": 10,
            "img": "docs/screenshots/10-producto-eliminado.png",
            "title": "Notificación tras la Eliminación Definitiva del Registro en Base de Datos",
            "text": "Tras procesar el borrado en SQLite, el sistema emite la confirmación presentada en la Figura 10:",
            "note": "SnackBar flotante que confirma la eliminación del producto y redirecciona a la lista general con las métricas recalculadas."
        },
        {
            "num": 11,
            "img": "docs/screenshots/11-dashboard-actualizado.png",
            "title": "Dashboard Actualizado Reactivamente tras Operaciones de Mutación",
            "text": "La actualización inmediata de los indicadores consolidados se evidencia en la Figura 11:",
            "note": "Los valores consolidados de productos, existencias y valoración económica se recalculan en tiempo real sin requerir reinicio de la aplicación."
        },
        {
            "num": 12,
            "img": "docs/screenshots/12-estado-carga.png",
            "title": "Estado Visual de Carga y Sincronización de Datos",
            "text": "Durante la comunicación asíncrona con el servidor, la aplicación adopta el estado presentado en la Figura 12:",
            "note": "Indicador circular de progreso (CircularProgressIndicator) centrado con mensaje descriptivo durante las llamadas HTTP."
        },
        {
            "num": 13,
            "img": "docs/screenshots/13-estado-error.png",
            "title": "Estado Visual de Error de Comunicación con Mecanismo de Reintento",
            "text": "Ante fallos de conexión o indisponibilidad del servicio, la interfaz muestra la vista controlada exhibida en la Figura 13:",
            "note": "Pantalla amigable con mensaje capturado por ApiException y botón interactivo 'Reintentar' para restablecer la conexión."
        },
        {
            "num": 14,
            "img": "docs/screenshots/14-estado-vacio.png",
            "title": "Estado Visual de Catálogo Vacío sin Registros en Inventario",
            "text": "Cuando la base de datos no contiene elementos, se presenta la vista ilustrada en la Figura 14:",
            "note": "Vista orientativa con iconografía alusiva y mensaje claro que guía al usuario a realizar su primer registro de producto."
        }
    ]

    # Proporción de las capturas: 9:19.5 (155 pt de ancho x 336 pt de alto)
    # Permite que la introducción, el título APA, la imagen y la nota quepan
    # holgadamente y sin desbordes en cada página.
    img_w = 155
    img_h = 336

    for fig in figures_def:
        fig_elements = []
        fig_elements.append(Paragraph(fig["text"], fig_intro_style))
        fig_elements.append(Paragraph(f"<b>Figura {fig['num']}</b>", fig_label_style))
        fig_elements.append(Paragraph(fig["title"], fig_title_style))
        
        if os.path.exists(fig["img"]):
            im = Image(fig["img"], width=img_w, height=img_h)
            im.hAlign = 'CENTER'
            fig_elements.append(im)
        else:
            fig_elements.append(Paragraph(f"[Captura no encontrada en {fig['img']}]", body_style))
            
        fig_elements.append(Paragraph(f"<i>Nota.</i> {fig['note']}", fig_note_style))
        
        story.append(KeepTogether(fig_elements))
        story.append(PageBreak())

    # Callback para la numeración de páginas en la esquina superior derecha (APA 7)
    def add_page_number(canvas, doc):
        canvas.saveState()
        canvas.setFont('Times-Roman', 10)
        page_num = str(doc.page)
        canvas.drawRightString(letter[0] - 72, letter[1] - 36, page_num)
        canvas.restoreState()

    doc.build(story, onFirstPage=add_page_number, onLaterPages=add_page_number)
    print(f"Documento generado exitosamente en: {filename}")

if __name__ == '__main__':
    build_pdf()
