/* Server.c generated by valac 0.22.1, the Vala compiler
 * generated from Server.vala, do not modify */

/*
 * Qetesh Web Interface
 * A tiny webserver that runs Qetesh applications,
 * written in Vala
 * 
 * Quick note:
 *  - Most stuff that developers will care about is actually in
 * libqetesh. The server itself does a small number of things: loads
 * the framework library (libqetesh), loads application modules,
 * and runs a very simple web server to funnel requests through the
 * framework to the application and responses back again.
 * 
 *  - Qetesh has few web server features inbuilt. It cannot even serve
 * files at this stage. It doesn't have request rate limiting. Its 
 * purpose is entirely to serve the data and events layers of the 
 * framework. For everything else, there's Apache.
 * 
 * - The server package also contains the frontend files for the
 * framework.
 * 
 * -----------------------------------------
 * 
 * Copyright 2015 Dan Ladds <Dan@el-topo.co.uk>
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
#include <libqetesh.h>
#include <stdlib.h>
#include <string.h>
#include <gio/gio.h>


#define QETESH_WEB_SERVER_TYPE_SERVER (qetesh_web_server_server_get_type ())
#define QETESH_WEB_SERVER_SERVER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServer))
#define QETESH_WEB_SERVER_SERVER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServerClass))
#define QETESH_WEB_SERVER_IS_SERVER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_WEB_SERVER_TYPE_SERVER))
#define QETESH_WEB_SERVER_IS_SERVER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_WEB_SERVER_TYPE_SERVER))
#define QETESH_WEB_SERVER_SERVER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServerClass))

typedef struct _QeteshWebServerServer QeteshWebServerServer;
typedef struct _QeteshWebServerServerClass QeteshWebServerServerClass;
typedef struct _QeteshWebServerServerPrivate QeteshWebServerServerPrivate;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))

#define QETESH_WEB_SERVER_SERVER_TYPE_SOURCE (qetesh_web_server_server_source_get_type ())
#define QETESH_WEB_SERVER_SERVER_SOURCE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSource))
#define QETESH_WEB_SERVER_SERVER_SOURCE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSourceClass))
#define QETESH_WEB_SERVER_SERVER_IS_SOURCE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_WEB_SERVER_SERVER_TYPE_SOURCE))
#define QETESH_WEB_SERVER_SERVER_IS_SOURCE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_WEB_SERVER_SERVER_TYPE_SOURCE))
#define QETESH_WEB_SERVER_SERVER_SOURCE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSourceClass))

typedef struct _QeteshWebServerServerSource QeteshWebServerServerSource;
typedef struct _QeteshWebServerServerSourceClass QeteshWebServerServerSourceClass;
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))
#define _g_main_loop_unref0(var) ((var == NULL) ? NULL : (var = (g_main_loop_unref (var), NULL)))

#define QETESH_WEB_SERVER_TYPE_REQUEST_ROUTER (qetesh_web_server_request_router_get_type ())
#define QETESH_WEB_SERVER_REQUEST_ROUTER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), QETESH_WEB_SERVER_TYPE_REQUEST_ROUTER, QeteshWebServerRequestRouter))
#define QETESH_WEB_SERVER_REQUEST_ROUTER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), QETESH_WEB_SERVER_TYPE_REQUEST_ROUTER, QeteshWebServerRequestRouterClass))
#define QETESH_WEB_SERVER_IS_REQUEST_ROUTER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), QETESH_WEB_SERVER_TYPE_REQUEST_ROUTER))
#define QETESH_WEB_SERVER_IS_REQUEST_ROUTER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), QETESH_WEB_SERVER_TYPE_REQUEST_ROUTER))
#define QETESH_WEB_SERVER_REQUEST_ROUTER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), QETESH_WEB_SERVER_TYPE_REQUEST_ROUTER, QeteshWebServerRequestRouterClass))

typedef struct _QeteshWebServerRequestRouter QeteshWebServerRequestRouter;
typedef struct _QeteshWebServerRequestRouterClass QeteshWebServerRequestRouterClass;
typedef struct _QeteshWebServerServerSourcePrivate QeteshWebServerServerSourcePrivate;

struct _QeteshWebServerServer {
	GObject parent_instance;
	QeteshWebServerServerPrivate * priv;
};

struct _QeteshWebServerServerClass {
	GObjectClass parent_class;
};

struct _QeteshWebServerServerPrivate {
	QeteshWebServerContext* context;
};

struct _QeteshWebServerServerSource {
	GObject parent_instance;
	QeteshWebServerServerSourcePrivate * priv;
};

struct _QeteshWebServerServerSourceClass {
	GObjectClass parent_class;
};

struct _QeteshWebServerServerSourcePrivate {
	guint16 _port;
};


static gpointer qetesh_web_server_server_parent_class = NULL;
static QeteshWebServerServer* qetesh_web_server_server__Current;
static QeteshWebServerServer* qetesh_web_server_server__Current = NULL;
static gpointer qetesh_web_server_server_source_parent_class = NULL;

GType qetesh_web_server_server_get_type (void) G_GNUC_CONST;
#define QETESH_WEB_SERVER_SERVER_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServerPrivate))
enum  {
	QETESH_WEB_SERVER_SERVER_DUMMY_PROPERTY
};
gint qetesh_web_server_server_main (gchar** args, int args_length1);
QeteshWebServerServer* qetesh_web_server_server_get_Current (void);
static QeteshWebServerServer* qetesh_web_server_server_new (void);
static QeteshWebServerServer* qetesh_web_server_server_construct (GType object_type);
static void qetesh_web_server_server_set_Current (QeteshWebServerServer* value);
void qetesh_web_server_server_Listen (QeteshWebServerServer* self);
QeteshWebServerServerSource* qetesh_web_server_server_source_new (guint16 port);
QeteshWebServerServerSource* qetesh_web_server_server_source_construct (GType object_type, guint16 port);
GType qetesh_web_server_server_source_get_type (void) G_GNUC_CONST;
gboolean qetesh_web_server_server_DispatchRequest (QeteshWebServerServer* self, GSocketConnection* c, GObject* s);
static gboolean _qetesh_web_server_server_DispatchRequest_g_threaded_socket_service_run (GThreadedSocketService* _sender, GSocketConnection* connection, GObject* source_object, gpointer self);
GType qetesh_web_server_request_router_get_type (void) G_GNUC_CONST;
QeteshWebServerRequestRouter* qetesh_web_server_request_router_new (QeteshHTTPRequest* req, QeteshWebServerContext* cxt);
QeteshWebServerRequestRouter* qetesh_web_server_request_router_construct (GType object_type, QeteshHTTPRequest* req, QeteshWebServerContext* cxt);
#define QETESH_WEB_SERVER_SERVER_SOURCE_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSourcePrivate))
enum  {
	QETESH_WEB_SERVER_SERVER_SOURCE_DUMMY_PROPERTY
};
static void qetesh_web_server_server_source_set_port (QeteshWebServerServerSource* self, guint16 value);
guint16 qetesh_web_server_server_source_get_port (QeteshWebServerServerSource* self);
static void qetesh_web_server_server_source_finalize (GObject* obj);
static void _vala_qetesh_web_server_server_source_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void _vala_qetesh_web_server_server_source_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);
static void qetesh_web_server_server_finalize (GObject* obj);
static void _vala_qetesh_web_server_server_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void _vala_qetesh_web_server_server_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);


/** 
 * This is where it all begins...
 * Start the program and create the server.
 * Instruct the server to listen.
 * 
 * @param args Command line arguments
 * @return 0
 * 
*/
gint qetesh_web_server_server_main (gchar** args, int args_length1) {
	gint result = 0;
	QeteshWebServerServer* _tmp0_ = NULL;
	QeteshWebServerServer* _tmp1_ = NULL;
	QeteshWebServerServer* _tmp2_ = NULL;
	QeteshWebServerServer* _tmp3_ = NULL;
	QeteshWebServerServer* _tmp4_ = NULL;
	QeteshWebServerServer* _tmp5_ = NULL;
	_tmp0_ = qetesh_web_server_server_get_Current ();
	_tmp1_ = _tmp0_;
	_tmp2_ = qetesh_web_server_server_new ();
	_tmp3_ = _tmp2_;
	qetesh_web_server_server_set_Current (_tmp3_);
	_g_object_unref0 (_tmp3_);
	_tmp4_ = qetesh_web_server_server_get_Current ();
	_tmp5_ = _tmp4_;
	qetesh_web_server_server_Listen (_tmp5_);
	result = 0;
	return result;
}


int main (int argc, char ** argv) {
	return qetesh_web_server_server_main (argv, argc);
}


/**
 * Start a server.
 * 
 * Create an instance of the Server class, which will proceed
 * to load modules and read its config file
**/
static QeteshWebServerServer* qetesh_web_server_server_construct (GType object_type) {
	QeteshWebServerServer * self = NULL;
	QeteshWebServerContext* _tmp0_ = NULL;
	QeteshWebServerContext* _tmp1_ = NULL;
	QeteshErrorManager* _tmp2_ = NULL;
	QeteshWebServerContext* _tmp3_ = NULL;
	QeteshErrorManager* _tmp4_ = NULL;
	QeteshWebServerContext* _tmp5_ = NULL;
	QeteshErrorManager* _tmp6_ = NULL;
	QeteshWebServerContext* _tmp7_ = NULL;
	QeteshErrorManager* _tmp8_ = NULL;
	QeteshWebServerContext* _tmp9_ = NULL;
	QeteshWebServerContext* _tmp10_ = NULL;
	QeteshConfigFile* _tmp11_ = NULL;
	QeteshWebServerContext* _tmp12_ = NULL;
	QeteshErrorManager* _tmp13_ = NULL;
	QeteshWebServerContext* _tmp14_ = NULL;
	QeteshWebServerContext* _tmp15_ = NULL;
	QeteshDataDBManager* _tmp16_ = NULL;
	QeteshWebServerContext* _tmp17_ = NULL;
	QeteshErrorManager* _tmp18_ = NULL;
	QeteshWebServerContext* _tmp19_ = NULL;
	QeteshWebServerContext* _tmp20_ = NULL;
	QeteshModuleManager* _tmp21_ = NULL;
	QeteshWebServerContext* _tmp22_ = NULL;
	QeteshModuleManager* _tmp23_ = NULL;
	self = (QeteshWebServerServer*) g_object_new (object_type, NULL);
	_tmp0_ = qetesh_web_server_context_new ();
	_g_object_unref0 (self->priv->context);
	self->priv->context = _tmp0_;
	_tmp1_ = self->priv->context;
	_tmp2_ = qetesh_error_manager_new ();
	_g_object_unref0 (_tmp1_->Err);
	_tmp1_->Err = _tmp2_;
	_tmp3_ = self->priv->context;
	_tmp4_ = _tmp3_->Err;
	qetesh_error_manager_WriteMessage (_tmp4_, "------------------------\n\n\n", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp5_ = self->priv->context;
	_tmp6_ = _tmp5_->Err;
	qetesh_error_manager_WriteMessage (_tmp6_, "Starting server :)", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp7_ = self->priv->context;
	_tmp8_ = _tmp7_->Err;
	qetesh_error_manager_WriteMessage (_tmp8_, "Loading config file...", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp9_ = self->priv->context;
	_tmp10_ = self->priv->context;
	_tmp11_ = qetesh_config_file_new (_tmp10_, QETESH_CONFIG_FILE_DCONFIG_FILE);
	_g_object_unref0 (_tmp9_->Configuration);
	_tmp9_->Configuration = _tmp11_;
	_tmp12_ = self->priv->context;
	_tmp13_ = _tmp12_->Err;
	qetesh_error_manager_WriteMessage (_tmp13_, "Loading databases...", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp14_ = self->priv->context;
	_tmp15_ = self->priv->context;
	_tmp16_ = qetesh_data_db_manager_new (_tmp15_);
	_g_object_unref0 (_tmp14_->Databases);
	_tmp14_->Databases = _tmp16_;
	_tmp17_ = self->priv->context;
	_tmp18_ = _tmp17_->Err;
	qetesh_error_manager_WriteMessage (_tmp18_, "Loading modules...", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp19_ = self->priv->context;
	_tmp20_ = self->priv->context;
	_tmp21_ = qetesh_module_manager_new (_tmp20_);
	_g_object_unref0 (_tmp19_->Modules);
	_tmp19_->Modules = _tmp21_;
	_tmp22_ = self->priv->context;
	_tmp23_ = _tmp22_->Modules;
	qetesh_module_manager_LoadModules (_tmp23_);
	return self;
}


static QeteshWebServerServer* qetesh_web_server_server_new (void) {
	return qetesh_web_server_server_construct (QETESH_WEB_SERVER_TYPE_SERVER);
}


/** 
 * Listen on a TCP port for HTTP connections
 * 
 * Listens on a specified port for HTTP connections, which are
 * dispatched to child threads for processing and response
 * 
 * @param port Port to listen on
 * 
**/
static gboolean _qetesh_web_server_server_DispatchRequest_g_threaded_socket_service_run (GThreadedSocketService* _sender, GSocketConnection* connection, GObject* source_object, gpointer self) {
	gboolean result;
	result = qetesh_web_server_server_DispatchRequest (self, connection, source_object);
	return result;
}


void qetesh_web_server_server_Listen (QeteshWebServerServer* self) {
	GThreadedSocketService* service = NULL;
	QeteshWebServerContext* _tmp0_ = NULL;
	QeteshConfigFile* _tmp1_ = NULL;
	gint _tmp2_ = 0;
	gint _tmp3_ = 0;
	GThreadedSocketService* _tmp4_ = NULL;
	QeteshWebServerContext* _tmp5_ = NULL;
	QeteshErrorManager* _tmp6_ = NULL;
	QeteshWebServerContext* _tmp7_ = NULL;
	QeteshConfigFile* _tmp8_ = NULL;
	gint _tmp9_ = 0;
	gint _tmp10_ = 0;
	gchar* _tmp11_ = NULL;
	gchar* _tmp12_ = NULL;
	QeteshWebServerContext* _tmp40_ = NULL;
	QeteshErrorManager* _tmp41_ = NULL;
	GMainLoop* loop = NULL;
	GMainLoop* _tmp42_ = NULL;
	GMainLoop* _tmp43_ = NULL;
	GError * _inner_error_ = NULL;
	g_return_if_fail (self != NULL);
	_tmp0_ = self->priv->context;
	_tmp1_ = _tmp0_->Configuration;
	_tmp2_ = qetesh_config_file_get_MaxThreads (_tmp1_);
	_tmp3_ = _tmp2_;
	_tmp4_ = (GThreadedSocketService*) g_threaded_socket_service_new (_tmp3_);
	service = _tmp4_;
	_tmp5_ = self->priv->context;
	_tmp6_ = _tmp5_->Err;
	_tmp7_ = self->priv->context;
	_tmp8_ = _tmp7_->Configuration;
	_tmp9_ = qetesh_config_file_get_MaxThreads (_tmp8_);
	_tmp10_ = _tmp9_;
	_tmp11_ = g_strdup_printf ("Starting with %d max threads", _tmp10_);
	_tmp12_ = _tmp11_;
	qetesh_error_manager_WriteMessage (_tmp6_, _tmp12_, QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_g_free0 (_tmp12_);
	{
		QeteshWebServerContext* _tmp13_ = NULL;
		QeteshErrorManager* _tmp14_ = NULL;
		QeteshWebServerContext* _tmp15_ = NULL;
		QeteshConfigFile* _tmp16_ = NULL;
		guint16 _tmp17_ = 0U;
		guint16 _tmp18_ = 0U;
		gchar* _tmp19_ = NULL;
		gchar* _tmp20_ = NULL;
		GThreadedSocketService* _tmp21_ = NULL;
		QeteshWebServerContext* _tmp22_ = NULL;
		QeteshConfigFile* _tmp23_ = NULL;
		guint16 _tmp24_ = 0U;
		guint16 _tmp25_ = 0U;
		QeteshWebServerContext* _tmp26_ = NULL;
		QeteshConfigFile* _tmp27_ = NULL;
		guint16 _tmp28_ = 0U;
		guint16 _tmp29_ = 0U;
		QeteshWebServerServerSource* _tmp30_ = NULL;
		QeteshWebServerServerSource* _tmp31_ = NULL;
		GThreadedSocketService* _tmp32_ = NULL;
		GThreadedSocketService* _tmp33_ = NULL;
		_tmp13_ = self->priv->context;
		_tmp14_ = _tmp13_->Err;
		_tmp15_ = self->priv->context;
		_tmp16_ = _tmp15_->Configuration;
		_tmp17_ = qetesh_config_file_get_ListenPort (_tmp16_);
		_tmp18_ = _tmp17_;
		_tmp19_ = g_strdup_printf ("Listening on port %d", (gint) _tmp18_);
		_tmp20_ = _tmp19_;
		qetesh_error_manager_WriteMessage (_tmp14_, _tmp20_, QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
		_g_free0 (_tmp20_);
		_tmp21_ = service;
		_tmp22_ = self->priv->context;
		_tmp23_ = _tmp22_->Configuration;
		_tmp24_ = qetesh_config_file_get_ListenPort (_tmp23_);
		_tmp25_ = _tmp24_;
		_tmp26_ = self->priv->context;
		_tmp27_ = _tmp26_->Configuration;
		_tmp28_ = qetesh_config_file_get_ListenPort (_tmp27_);
		_tmp29_ = _tmp28_;
		_tmp30_ = qetesh_web_server_server_source_new (_tmp29_);
		_tmp31_ = _tmp30_;
		g_socket_listener_add_inet_port ((GSocketListener*) _tmp21_, _tmp25_, (GObject*) _tmp31_, &_inner_error_);
		_g_object_unref0 (_tmp31_);
		if (_inner_error_ != NULL) {
			goto __catch0_g_error;
		}
		_tmp32_ = service;
		g_signal_connect_object (_tmp32_, "run", (GCallback) _qetesh_web_server_server_DispatchRequest_g_threaded_socket_service_run, self, 0);
		_tmp33_ = service;
		g_socket_service_start ((GSocketService*) _tmp33_);
	}
	goto __finally0;
	__catch0_g_error:
	{
		GError* e = NULL;
		QeteshWebServerContext* _tmp34_ = NULL;
		QeteshErrorManager* _tmp35_ = NULL;
		GError* _tmp36_ = NULL;
		const gchar* _tmp37_ = NULL;
		gchar* _tmp38_ = NULL;
		gchar* _tmp39_ = NULL;
		e = _inner_error_;
		_inner_error_ = NULL;
		_tmp34_ = self->priv->context;
		_tmp35_ = _tmp34_->Err;
		_tmp36_ = e;
		_tmp37_ = _tmp36_->message;
		_tmp38_ = g_strdup_printf ("Error while trying to listen on port: %s", _tmp37_);
		_tmp39_ = _tmp38_;
		qetesh_error_manager_WriteMessage (_tmp35_, _tmp39_, QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_CRITICAL, NULL);
		_g_free0 (_tmp39_);
		_g_error_free0 (e);
		_g_object_unref0 (service);
		return;
	}
	__finally0:
	if (_inner_error_ != NULL) {
		_g_object_unref0 (service);
		g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
		g_clear_error (&_inner_error_);
		return;
	}
	_tmp40_ = self->priv->context;
	_tmp41_ = _tmp40_->Err;
	qetesh_error_manager_WriteMessage (_tmp41_, "Starting main loop...", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp42_ = g_main_loop_new (NULL, FALSE);
	loop = _tmp42_;
	_tmp43_ = loop;
	g_main_loop_run (_tmp43_);
	_g_main_loop_unref0 (loop);
	_g_object_unref0 (service);
}


/** 
 * Dispatch an incoming connection and handle
 * 
 * Creates a new {@link HTTPRequest} to handle an incoming request
 * 
 * First function called in individual request threads
 * 
 * @param c Socket connection to inbound client
 * @param s Source object
 * @return false
 * 
**/
gboolean qetesh_web_server_server_DispatchRequest (QeteshWebServerServer* self, GSocketConnection* c, GObject* s) {
	gboolean result = FALSE;
	QeteshWebServerContext* _tmp0_ = NULL;
	QeteshErrorManager* _tmp1_ = NULL;
	QeteshHTTPRequest* req = NULL;
	GSocketConnection* _tmp2_ = NULL;
	QeteshWebServerContext* _tmp3_ = NULL;
	QeteshHTTPRequest* _tmp4_ = NULL;
	QeteshWebServerContext* _tmp5_ = NULL;
	QeteshErrorManager* _tmp6_ = NULL;
	QeteshWebServerRequestRouter* router = NULL;
	QeteshWebServerContext* _tmp7_ = NULL;
	QeteshWebServerRequestRouter* _tmp8_ = NULL;
	g_return_val_if_fail (self != NULL, FALSE);
	g_return_val_if_fail (c != NULL, FALSE);
	g_return_val_if_fail (s != NULL, FALSE);
	_tmp0_ = self->priv->context;
	_tmp1_ = _tmp0_->Err;
	qetesh_error_manager_WriteMessage (_tmp1_, "\n\n\nServer Dispatching Request", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp2_ = c;
	_tmp3_ = self->priv->context;
	_tmp4_ = qetesh_http_request_new (_tmp2_, _tmp3_);
	req = _tmp4_;
	qetesh_http_request_Handle (req);
	_tmp5_ = self->priv->context;
	_tmp6_ = _tmp5_->Err;
	qetesh_error_manager_WriteMessage (_tmp6_, "\n\n\nServer Routing Request", QETESH_ERROR_MANAGER_QERROR_CLASS_QETESH_DEBUG, NULL);
	_tmp7_ = self->priv->context;
	_tmp8_ = qetesh_web_server_request_router_new (req, _tmp7_);
	router = _tmp8_;
	result = FALSE;
	_g_object_unref0 (router);
	_g_object_unref0 (req);
	return result;
}


QeteshWebServerServer* qetesh_web_server_server_get_Current (void) {
	QeteshWebServerServer* result;
	QeteshWebServerServer* _tmp0_ = NULL;
	_tmp0_ = qetesh_web_server_server__Current;
	result = _tmp0_;
	return result;
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void qetesh_web_server_server_set_Current (QeteshWebServerServer* value) {
	QeteshWebServerServer* _tmp0_ = NULL;
	QeteshWebServerServer* _tmp1_ = NULL;
	_tmp0_ = value;
	_tmp1_ = _g_object_ref0 (_tmp0_);
	_g_object_unref0 (qetesh_web_server_server__Current);
	qetesh_web_server_server__Current = _tmp1_;
}


QeteshWebServerServerSource* qetesh_web_server_server_source_construct (GType object_type, guint16 port) {
	QeteshWebServerServerSource * self = NULL;
	guint16 _tmp0_ = 0U;
	self = (QeteshWebServerServerSource*) g_object_new (object_type, NULL);
	_tmp0_ = port;
	qetesh_web_server_server_source_set_port (self, _tmp0_);
	return self;
}


QeteshWebServerServerSource* qetesh_web_server_server_source_new (guint16 port) {
	return qetesh_web_server_server_source_construct (QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, port);
}


guint16 qetesh_web_server_server_source_get_port (QeteshWebServerServerSource* self) {
	guint16 result;
	guint16 _tmp0_ = 0U;
	g_return_val_if_fail (self != NULL, 0U);
	_tmp0_ = self->priv->_port;
	result = _tmp0_;
	return result;
}


static void qetesh_web_server_server_source_set_port (QeteshWebServerServerSource* self, guint16 value) {
	guint16 _tmp0_ = 0U;
	g_return_if_fail (self != NULL);
	_tmp0_ = value;
	self->priv->_port = _tmp0_;
}


static void qetesh_web_server_server_source_class_init (QeteshWebServerServerSourceClass * klass) {
	qetesh_web_server_server_source_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (QeteshWebServerServerSourcePrivate));
	G_OBJECT_CLASS (klass)->get_property = _vala_qetesh_web_server_server_source_get_property;
	G_OBJECT_CLASS (klass)->set_property = _vala_qetesh_web_server_server_source_set_property;
	G_OBJECT_CLASS (klass)->finalize = qetesh_web_server_server_source_finalize;
}


static void qetesh_web_server_server_source_instance_init (QeteshWebServerServerSource * self) {
	self->priv = QETESH_WEB_SERVER_SERVER_SOURCE_GET_PRIVATE (self);
}


static void qetesh_web_server_server_source_finalize (GObject* obj) {
	QeteshWebServerServerSource * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSource);
	G_OBJECT_CLASS (qetesh_web_server_server_source_parent_class)->finalize (obj);
}


/**
 * Represents the source of an individual request.
 * 
 * Currently stores just the source port.
**/
GType qetesh_web_server_server_source_get_type (void) {
	static volatile gsize qetesh_web_server_server_source_type_id__volatile = 0;
	if (g_once_init_enter (&qetesh_web_server_server_source_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (QeteshWebServerServerSourceClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) qetesh_web_server_server_source_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (QeteshWebServerServerSource), 0, (GInstanceInitFunc) qetesh_web_server_server_source_instance_init, NULL };
		GType qetesh_web_server_server_source_type_id;
		qetesh_web_server_server_source_type_id = g_type_register_static (G_TYPE_OBJECT, "QeteshWebServerServerSource", &g_define_type_info, 0);
		g_once_init_leave (&qetesh_web_server_server_source_type_id__volatile, qetesh_web_server_server_source_type_id);
	}
	return qetesh_web_server_server_source_type_id__volatile;
}


static void _vala_qetesh_web_server_server_source_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	QeteshWebServerServerSource * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSource);
	switch (property_id) {
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void _vala_qetesh_web_server_server_source_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	QeteshWebServerServerSource * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, QETESH_WEB_SERVER_SERVER_TYPE_SOURCE, QeteshWebServerServerSource);
	switch (property_id) {
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void qetesh_web_server_server_class_init (QeteshWebServerServerClass * klass) {
	qetesh_web_server_server_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (QeteshWebServerServerPrivate));
	G_OBJECT_CLASS (klass)->get_property = _vala_qetesh_web_server_server_get_property;
	G_OBJECT_CLASS (klass)->set_property = _vala_qetesh_web_server_server_set_property;
	G_OBJECT_CLASS (klass)->finalize = qetesh_web_server_server_finalize;
}


static void qetesh_web_server_server_instance_init (QeteshWebServerServer * self) {
	self->priv = QETESH_WEB_SERVER_SERVER_GET_PRIVATE (self);
}


static void qetesh_web_server_server_finalize (GObject* obj) {
	QeteshWebServerServer * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServer);
	_g_object_unref0 (self->priv->context);
	G_OBJECT_CLASS (qetesh_web_server_server_parent_class)->finalize (obj);
}


/** 
 * The main Qetesh web server class
 * 
 * An instance of this class represents a server instance.
 * Contains a static main() method which creates a single server.
 * This class handles listening for requests and assigning them to worker threads.
**/
GType qetesh_web_server_server_get_type (void) {
	static volatile gsize qetesh_web_server_server_type_id__volatile = 0;
	if (g_once_init_enter (&qetesh_web_server_server_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (QeteshWebServerServerClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) qetesh_web_server_server_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (QeteshWebServerServer), 0, (GInstanceInitFunc) qetesh_web_server_server_instance_init, NULL };
		GType qetesh_web_server_server_type_id;
		qetesh_web_server_server_type_id = g_type_register_static (G_TYPE_OBJECT, "QeteshWebServerServer", &g_define_type_info, 0);
		g_once_init_leave (&qetesh_web_server_server_type_id__volatile, qetesh_web_server_server_type_id);
	}
	return qetesh_web_server_server_type_id__volatile;
}


static void _vala_qetesh_web_server_server_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	QeteshWebServerServer * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServer);
	switch (property_id) {
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void _vala_qetesh_web_server_server_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	QeteshWebServerServer * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, QETESH_WEB_SERVER_TYPE_SERVER, QeteshWebServerServer);
	switch (property_id) {
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}



