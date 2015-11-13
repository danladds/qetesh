/* FileParser.c generated by valac 0.22.1, the Vala compiler
 * generated from FileParser.vala, do not modify */

/*
 * FileParser.vala
 * 
 * Copyright 2014 Dan Ladds <Dan@el-topo.co.uk>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */

#include <glib.h>
#include <glib-object.h>


#define QETESH_TYPE_FILE_PARSER (qetesh_file_parser_get_type ())
#define QETESH_FILE_PARSER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_TYPE_FILE_PARSER, QeteshFileParser))
#define QETESH_IS_FILE_PARSER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_TYPE_FILE_PARSER))
#define QETESH_FILE_PARSER_GET_INTERFACE(obj) (G_TYPE_INSTANCE_GET_INTERFACE ((obj), QETESH_TYPE_FILE_PARSER, QeteshFileParserIface))

typedef struct _QeteshFileParser QeteshFileParser;
typedef struct _QeteshFileParserIface QeteshFileParserIface;

struct _QeteshFileParserIface {
	GTypeInterface parent_iface;
};



GType qetesh_file_parser_get_type (void) G_GNUC_CONST;
void qetesh_file_parser_ReadInto (QeteshFileParser* self, gconstpointer obj);


void qetesh_file_parser_ReadInto (QeteshFileParser* self, gconstpointer obj) {
}


static void qetesh_file_parser_base_init (QeteshFileParserIface * iface) {
	static gboolean initialized = FALSE;
	if (!initialized) {
		initialized = TRUE;
	}
}


GType qetesh_file_parser_get_type (void) {
	static volatile gsize qetesh_file_parser_type_id__volatile = 0;
	if (g_once_init_enter (&qetesh_file_parser_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (QeteshFileParserIface), (GBaseInitFunc) qetesh_file_parser_base_init, (GBaseFinalizeFunc) NULL, (GClassInitFunc) NULL, (GClassFinalizeFunc) NULL, NULL, 0, 0, (GInstanceInitFunc) NULL, NULL };
		GType qetesh_file_parser_type_id;
		qetesh_file_parser_type_id = g_type_register_static (G_TYPE_INTERFACE, "QeteshFileParser", &g_define_type_info, 0);
		g_type_interface_add_prerequisite (qetesh_file_parser_type_id, G_TYPE_OBJECT);
		g_once_init_leave (&qetesh_file_parser_type_id__volatile, qetesh_file_parser_type_id);
	}
	return qetesh_file_parser_type_id__volatile;
}



