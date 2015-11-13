/* QDatabase.c generated by valac 0.22.1, the Vala compiler
 * generated from QDatabase.vala, do not modify */

/*
 * QDatabase.vala
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


#define QETESH_DATA_TYPE_QDATABASE (qetesh_data_qdatabase_get_type ())
#define QETESH_DATA_QDATABASE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabase))
#define QETESH_DATA_QDATABASE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabaseClass))
#define QETESH_DATA_IS_QDATABASE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_DATA_TYPE_QDATABASE))
#define QETESH_DATA_IS_QDATABASE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_DATA_TYPE_QDATABASE))
#define QETESH_DATA_QDATABASE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabaseClass))

typedef struct _QeteshDataQDatabase QeteshDataQDatabase;
typedef struct _QeteshDataQDatabaseClass QeteshDataQDatabaseClass;
typedef struct _QeteshDataQDatabasePrivate QeteshDataQDatabasePrivate;

#define QETESH_DATA_TYPE_QDATABASE_CONN (qetesh_data_qdatabase_conn_get_type ())
#define QETESH_DATA_QDATABASE_CONN(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_DATA_TYPE_QDATABASE_CONN, QeteshDataQDatabaseConn))
#define QETESH_DATA_QDATABASE_CONN_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_DATA_TYPE_QDATABASE_CONN, QeteshDataQDatabaseConnClass))
#define QETESH_DATA_IS_QDATABASE_CONN(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_DATA_TYPE_QDATABASE_CONN))
#define QETESH_DATA_IS_QDATABASE_CONN_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_DATA_TYPE_QDATABASE_CONN))
#define QETESH_DATA_QDATABASE_CONN_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_DATA_TYPE_QDATABASE_CONN, QeteshDataQDatabaseConnClass))

typedef struct _QeteshDataQDatabaseConn QeteshDataQDatabaseConn;
typedef struct _QeteshDataQDatabaseConnClass QeteshDataQDatabaseConnClass;

#define QETESH_CONFIG_FILE_TYPE_DB_CONFIG (qetesh_config_file_db_config_get_type ())
#define QETESH_CONFIG_FILE_DB_CONFIG(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_CONFIG_FILE_TYPE_DB_CONFIG, QeteshConfigFileDBConfig))
#define QETESH_CONFIG_FILE_DB_CONFIG_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_CONFIG_FILE_TYPE_DB_CONFIG, QeteshConfigFileDBConfigClass))
#define QETESH_CONFIG_FILE_IS_DB_CONFIG(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_CONFIG_FILE_TYPE_DB_CONFIG))
#define QETESH_CONFIG_FILE_IS_DB_CONFIG_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_CONFIG_FILE_TYPE_DB_CONFIG))
#define QETESH_CONFIG_FILE_DB_CONFIG_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_CONFIG_FILE_TYPE_DB_CONFIG, QeteshConfigFileDBConfigClass))

typedef struct _QeteshConfigFileDBConfig QeteshConfigFileDBConfig;
typedef struct _QeteshConfigFileDBConfigClass QeteshConfigFileDBConfigClass;

#define QETESH_TYPE_WEB_SERVER_CONTEXT (qetesh_web_server_context_get_type ())
#define QETESH_WEB_SERVER_CONTEXT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_TYPE_WEB_SERVER_CONTEXT, QeteshWebServerContext))
#define QETESH_WEB_SERVER_CONTEXT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_TYPE_WEB_SERVER_CONTEXT, QeteshWebServerContextClass))
#define QETESH_IS_WEB_SERVER_CONTEXT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_TYPE_WEB_SERVER_CONTEXT))
#define QETESH_IS_WEB_SERVER_CONTEXT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_TYPE_WEB_SERVER_CONTEXT))
#define QETESH_WEB_SERVER_CONTEXT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_TYPE_WEB_SERVER_CONTEXT, QeteshWebServerContextClass))

typedef struct _QeteshWebServerContext QeteshWebServerContext;
typedef struct _QeteshWebServerContextClass QeteshWebServerContextClass;
#define _qetesh_config_file_db_config_unref0(var) ((var == NULL) ? NULL : (var = (qetesh_config_file_db_config_unref (var), NULL)))
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))

typedef enum  {
	QETESH_DATA_QDB_ERROR_CONNECT,
	QETESH_DATA_QDB_ERROR_QUERY
} QeteshDataQDBError;
#define QETESH_DATA_QDB_ERROR qetesh_data_qdb_error_quark ()
struct _QeteshDataQDatabase {
	GObject parent_instance;
	QeteshDataQDatabasePrivate * priv;
};

struct _QeteshDataQDatabaseClass {
	GObjectClass parent_class;
	QeteshDataQDatabaseConn* (*Connect) (QeteshDataQDatabase* self, GError** error);
};

struct _QeteshDataQDatabasePrivate {
	QeteshConfigFileDBConfig* _Conf;
	QeteshWebServerContext* _Context;
};


static gpointer qetesh_data_qdatabase_parent_class = NULL;

GType qetesh_data_qdatabase_get_type (void) G_GNUC_CONST;
gpointer qetesh_data_qdatabase_conn_ref (gpointer instance);
void qetesh_data_qdatabase_conn_unref (gpointer instance);
GParamSpec* qetesh_data_param_spec_qdatabase_conn (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void qetesh_data_value_set_qdatabase_conn (GValue* value, gpointer v_object);
void qetesh_data_value_take_qdatabase_conn (GValue* value, gpointer v_object);
gpointer qetesh_data_value_get_qdatabase_conn (const GValue* value);
GType qetesh_data_qdatabase_conn_get_type (void) G_GNUC_CONST;
GQuark qetesh_data_qdb_error_quark (void);
gpointer qetesh_config_file_db_config_ref (gpointer instance);
void qetesh_config_file_db_config_unref (gpointer instance);
GParamSpec* qetesh_config_file_param_spec_db_config (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void qetesh_config_file_value_set_db_config (GValue* value, gpointer v_object);
void qetesh_config_file_value_take_db_config (GValue* value, gpointer v_object);
gpointer qetesh_config_file_value_get_db_config (const GValue* value);
GType qetesh_config_file_db_config_get_type (void) G_GNUC_CONST;
GType qetesh_web_server_context_get_type (void) G_GNUC_CONST;
#define QETESH_DATA_QDATABASE_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabasePrivate))
enum  {
	QETESH_DATA_QDATABASE_DUMMY_PROPERTY,
	QETESH_DATA_QDATABASE_CONF,
	QETESH_DATA_QDATABASE_CONTEXT
};
QeteshDataQDatabaseConn* qetesh_data_qdatabase_Connect (QeteshDataQDatabase* self, GError** error);
static QeteshDataQDatabaseConn* qetesh_data_qdatabase_real_Connect (QeteshDataQDatabase* self, GError** error);
QeteshDataQDatabase* qetesh_data_qdatabase_construct (GType object_type, QeteshConfigFileDBConfig* config, QeteshWebServerContext* sc);
static void qetesh_data_qdatabase_set_Context (QeteshDataQDatabase* self, QeteshWebServerContext* value);
static void qetesh_data_qdatabase_set_Conf (QeteshDataQDatabase* self, QeteshConfigFileDBConfig* value);
QeteshConfigFileDBConfig* qetesh_data_qdatabase_get_Conf (QeteshDataQDatabase* self);
QeteshWebServerContext* qetesh_data_qdatabase_get_Context (QeteshDataQDatabase* self);
static void qetesh_data_qdatabase_finalize (GObject* obj);
static void _vala_qetesh_data_qdatabase_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void _vala_qetesh_data_qdatabase_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);


static QeteshDataQDatabaseConn* qetesh_data_qdatabase_real_Connect (QeteshDataQDatabase* self, GError** error) {
	g_critical ("Type `%s' does not implement abstract method `qetesh_data_qdatabase_Connect'", g_type_name (G_TYPE_FROM_INSTANCE (self)));
	return NULL;
}


QeteshDataQDatabaseConn* qetesh_data_qdatabase_Connect (QeteshDataQDatabase* self, GError** error) {
	g_return_val_if_fail (self != NULL, NULL);
	return QETESH_DATA_QDATABASE_GET_CLASS (self)->Connect (self, error);
}


QeteshDataQDatabase* qetesh_data_qdatabase_construct (GType object_type, QeteshConfigFileDBConfig* config, QeteshWebServerContext* sc) {
	QeteshDataQDatabase * self = NULL;
	QeteshWebServerContext* _tmp0_ = NULL;
	QeteshConfigFileDBConfig* _tmp1_ = NULL;
	g_return_val_if_fail (config != NULL, NULL);
	g_return_val_if_fail (sc != NULL, NULL);
	self = (QeteshDataQDatabase*) g_object_new (object_type, NULL);
	_tmp0_ = sc;
	qetesh_data_qdatabase_set_Context (self, _tmp0_);
	_tmp1_ = config;
	qetesh_data_qdatabase_set_Conf (self, _tmp1_);
	return self;
}


QeteshConfigFileDBConfig* qetesh_data_qdatabase_get_Conf (QeteshDataQDatabase* self) {
	QeteshConfigFileDBConfig* result;
	QeteshConfigFileDBConfig* _tmp0_ = NULL;
	g_return_val_if_fail (self != NULL, NULL);
	_tmp0_ = self->priv->_Conf;
	result = _tmp0_;
	return result;
}


static gpointer _qetesh_config_file_db_config_ref0 (gpointer self) {
	return self ? qetesh_config_file_db_config_ref (self) : NULL;
}


static void qetesh_data_qdatabase_set_Conf (QeteshDataQDatabase* self, QeteshConfigFileDBConfig* value) {
	QeteshConfigFileDBConfig* _tmp0_ = NULL;
	QeteshConfigFileDBConfig* _tmp1_ = NULL;
	g_return_if_fail (self != NULL);
	_tmp0_ = value;
	_tmp1_ = _qetesh_config_file_db_config_ref0 (_tmp0_);
	_qetesh_config_file_db_config_unref0 (self->priv->_Conf);
	self->priv->_Conf = _tmp1_;
	g_object_notify ((GObject *) self, "Conf");
}


QeteshWebServerContext* qetesh_data_qdatabase_get_Context (QeteshDataQDatabase* self) {
	QeteshWebServerContext* result;
	QeteshWebServerContext* _tmp0_ = NULL;
	g_return_val_if_fail (self != NULL, NULL);
	_tmp0_ = self->priv->_Context;
	result = _tmp0_;
	return result;
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void qetesh_data_qdatabase_set_Context (QeteshDataQDatabase* self, QeteshWebServerContext* value) {
	QeteshWebServerContext* _tmp0_ = NULL;
	QeteshWebServerContext* _tmp1_ = NULL;
	g_return_if_fail (self != NULL);
	_tmp0_ = value;
	_tmp1_ = _g_object_ref0 (_tmp0_);
	_g_object_unref0 (self->priv->_Context);
	self->priv->_Context = _tmp1_;
	g_object_notify ((GObject *) self, "Context");
}


static void qetesh_data_qdatabase_class_init (QeteshDataQDatabaseClass * klass) {
	qetesh_data_qdatabase_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (QeteshDataQDatabasePrivate));
	QETESH_DATA_QDATABASE_CLASS (klass)->Connect = qetesh_data_qdatabase_real_Connect;
	G_OBJECT_CLASS (klass)->get_property = _vala_qetesh_data_qdatabase_get_property;
	G_OBJECT_CLASS (klass)->set_property = _vala_qetesh_data_qdatabase_set_property;
	G_OBJECT_CLASS (klass)->finalize = qetesh_data_qdatabase_finalize;
	g_object_class_install_property (G_OBJECT_CLASS (klass), QETESH_DATA_QDATABASE_CONF, qetesh_config_file_param_spec_db_config ("Conf", "Conf", "Conf", QETESH_CONFIG_FILE_TYPE_DB_CONFIG, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE));
	g_object_class_install_property (G_OBJECT_CLASS (klass), QETESH_DATA_QDATABASE_CONTEXT, g_param_spec_object ("Context", "Context", "Context", QETESH_TYPE_WEB_SERVER_CONTEXT, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE));
}


static void qetesh_data_qdatabase_instance_init (QeteshDataQDatabase * self) {
	self->priv = QETESH_DATA_QDATABASE_GET_PRIVATE (self);
}


static void qetesh_data_qdatabase_finalize (GObject* obj) {
	QeteshDataQDatabase * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabase);
	_qetesh_config_file_db_config_unref0 (self->priv->_Conf);
	_g_object_unref0 (self->priv->_Context);
	G_OBJECT_CLASS (qetesh_data_qdatabase_parent_class)->finalize (obj);
}


GType qetesh_data_qdatabase_get_type (void) {
	static volatile gsize qetesh_data_qdatabase_type_id__volatile = 0;
	if (g_once_init_enter (&qetesh_data_qdatabase_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (QeteshDataQDatabaseClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) qetesh_data_qdatabase_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (QeteshDataQDatabase), 0, (GInstanceInitFunc) qetesh_data_qdatabase_instance_init, NULL };
		GType qetesh_data_qdatabase_type_id;
		qetesh_data_qdatabase_type_id = g_type_register_static (G_TYPE_OBJECT, "QeteshDataQDatabase", &g_define_type_info, G_TYPE_FLAG_ABSTRACT);
		g_once_init_leave (&qetesh_data_qdatabase_type_id__volatile, qetesh_data_qdatabase_type_id);
	}
	return qetesh_data_qdatabase_type_id__volatile;
}


static void _vala_qetesh_data_qdatabase_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	QeteshDataQDatabase * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabase);
	switch (property_id) {
		case QETESH_DATA_QDATABASE_CONF:
		qetesh_config_file_value_set_db_config (value, qetesh_data_qdatabase_get_Conf (self));
		break;
		case QETESH_DATA_QDATABASE_CONTEXT:
		g_value_set_object (value, qetesh_data_qdatabase_get_Context (self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void _vala_qetesh_data_qdatabase_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	QeteshDataQDatabase * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, QETESH_DATA_TYPE_QDATABASE, QeteshDataQDatabase);
	switch (property_id) {
		case QETESH_DATA_QDATABASE_CONF:
		qetesh_data_qdatabase_set_Conf (self, qetesh_config_file_value_get_db_config (value));
		break;
		case QETESH_DATA_QDATABASE_CONTEXT:
		qetesh_data_qdatabase_set_Context (self, g_value_get_object (value));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


GQuark qetesh_data_qdb_error_quark (void) {
	return g_quark_from_static_string ("qetesh_data_qdb_error-quark");
}



