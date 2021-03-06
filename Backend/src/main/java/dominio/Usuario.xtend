package dominio

import componente.observadores.Mail
import componente.observadores.Mensaje
import componente.observadores.Observador
import dominio.Alimento.Grupo
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.Period
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors

import java.time.format.DateTimeFormatter
import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.annotation.JsonIgnore
import java.util.HashMap

@Accessors
class Usuario extends Entity {
	
	//static String DATE_PATTERN = "dd/MM/yyyy"
	static String DATE_PATTERN = "yyyy-MM-dd"
	String nombreYApellido
	String userName
	String password
	Double peso
	Double estatura
	@JsonIgnore LocalDate fechaDeNacimiento
	@JsonIgnore Set<CondicionAlimenticia> condicionesAlimenticias = new HashSet<CondicionAlimenticia>
	Set<Alimento> alimentosPreferidos = new HashSet<Alimento>
	Set<Alimento> alimentosDisgustados = new HashSet<Alimento>
	Rutina rutina
	List<Mensaje> mensajesInternos = new ArrayList<Mensaje>
	List<Observador> observadores = new ArrayList<Observador>
	List<Mail> mails = new ArrayList<Mail>	
	
	@JsonProperty("fechaDeNacimiento")
	def getFechaAsString() {
		formatter.format(this.fechaDeNacimiento)
	}
	
	@JsonProperty("fechaDeNacimiento")
	def setFecha(String fecha) {
		this.fechaDeNacimiento = LocalDate.parse(fecha, formatter)
	}

	def formatter() {
		DateTimeFormatter.ofPattern(DATE_PATTERN)
	}
	
	@JsonProperty("condicionesAlimenticias")
	def getCondicionesAlimenticias() {
		condicionesAlimenticias.map[condicion|condicion.getAsString()].toSet
		
	}
	
	@JsonProperty("condicionesAlimenticias")
	def transformCondicionesAlimenticias(Set<String> condicionesAsString) {
		val condiciones = new HashMap<String, CondicionAlimenticia>
		condiciones.put("Vegetariano", Vegetariano.getInstancia)
		condiciones.put("Vegano", Vegano.getInstancia)
		condiciones.put("Hipertenso", Hipertenso.getInstancia)
		condiciones.put("Diab??tico", Diabetico.getInstancia)
		condiciones.put("Cel??aco", Celiaco.getInstancia)
		condicionesAsString.forEach[condicion | condicionesAlimenticias.add(condiciones.get(condicion))]
	} 					 
	
	def indiceMasaCorporal() {
		peso / Math.pow(estatura, 2)
	}

	def edad() {
		val LocalDate fechaActual = LocalDate.now
		Period.between(fechaDeNacimiento, fechaActual).years
	}

	def agregarCondicionAlimenticia(CondicionAlimenticia _condicion) {
		condicionesAlimenticias.add(_condicion)
	}
	
	def eliminarCondicionAlimenticia(CondicionAlimenticia _condicion) {
		condicionesAlimenticias.remove(_condicion)
	}

	def agregarAlimentosPreferidos(Alimento _AlimetoPreferido) {
		alimentosPreferidos.add(_AlimetoPreferido)
	}

	def agregarAlimentoDisgustado(Alimento _AlimentoDigustado) {
		alimentosDisgustados.add(_AlimentoDigustado)
	}
	
	def eliminarAlimentoPreferido(Alimento _AlimetoPreferido) {
		alimentosPreferidos.remove(_AlimetoPreferido)
	}

	def eliminarAlimentoDisgustado(Alimento _AlimentoDigustado) {
		alimentosDisgustados.remove(_AlimentoDigustado)
	}
	
	def imcEsSaludable() {
		indiceMasaCorporal > 18 && indiceMasaCorporal < 30
	}

	def esSaludable() {
		(imcEsSaludable && condicionesAlimenticias.isEmpty) || subsanaCondicionesPreexistentes
	}

	def esMenorDe(Integer unaEdad) {
		edad() < unaEdad
	}

	def tieneGrasasEnSusAlimentosPreferidos() {
		alimentosPreferidos.exists[alimento|alimento.esDeGrupo(Grupo.ACEITES_GRASAS_AZUCARES)]
	}

	def tieneAlMenosDosFrutasEnSusAlimentosPreferidos() {
		alimentosPreferidos.filter[alimento|alimento.esDeGrupo(Grupo.HORTALIZAS_FRUTAS_SEMILLAS)].size >= 2
	}

	def tieneRutina(Rutina unaRutina) {
		rutina == unaRutina
	}
	
	def pesaMenosDe(int unPeso) {
		peso < unPeso
	} 

	def subsanaCondicionesPreexistentes() {
		condicionesAlimenticias.forall[condicionAlimenticia|condicionAlimenticia.subsanaCondicion(this)]
	}

	def esValido() {
		camposNoNulos && longitudNombreValida && alimentoPreferidosValidos && fechaNacimientoValida
	}

	def camposNoNulos() {
		!nombreYApellido.nullOrEmpty && peso !== null && estatura !== null && fechaDeNacimiento !== null &&
			rutina !== null
	}

	def longitudNombreValida() {
		nombreYApellido.length > 4
	}

	def alimentoPreferidosValidos() {
		!esHipertensoODiabetico || !alimentosPreferidos.empty
	}

	def esHipertensoODiabetico() {
		condicionesAlimenticias.exists [ condicionAlimenticia |
			condicionAlimenticia.class == Hipertenso || condicionAlimenticia.class == Diabetico
		]
	}

	def fechaNacimientoValida() {
		fechaDeNacimiento.isBefore(LocalDate.now)
	}
	
	def copiarReceta(Receta receta){
		val copia = new Receta(receta)
		copia.autor = this
		notificarObservadores(receta)
		copia
	}
	
	def notificarObservadores(Receta receta) {
		observadores.forEach[actualizar(receta)]
	}
	
	def agregarObservador(Observador observador) {
		observadores.add(observador)
	}
	
	def quitarObservador(Observador observador) {
		observadores.remove(observador)
	}
	
	def leGusta(Ingrediente ingrediente) {
		!alimentosDisgustados.contains(ingrediente.alimento)
	}
	
	def tieneCondicionAlimenticia(CondicionAlimenticia condicionAlimenticia) {
		condicionesAlimenticias.contains(condicionAlimenticia)
	}
	
	override cumpleCondicionDeBusqueda(String valorBusqueda) {
		nombreYApellido.toLowerCase.contains(valorBusqueda.toLowerCase) || userName.toLowerCase.equals(valorBusqueda.toLowerCase)
	}
	
	def recibirMensaje(Mensaje mensaje) {
		if (!mensajesInternos.empty) {
			val ultimoId = mensajesInternos.get(mensajesInternos.size - 1)
			mensaje.id = ultimoId.id + 1
		} else {
			mensaje.id = 1
		}
		mensajesInternos.add(mensaje)
	}
	
	def accederAUnMensaje(Integer mensajeId) {
		mensajesInternos.findFirst[message | message.id.equals(mensajeId)]
	}
	
	def visualizarMensaje(Mensaje mensaje) {
		System.out.println(accederAUnMensaje(mensaje.id).cuerpo.toString
						 + accederAUnMensaje(mensaje.id).remitente.toString
						 + accederAUnMensaje(mensaje.id).fechaYHoraDeEmision.toString
		)
		mensaje.leido = true
		mensaje.fechaYHoraDeLectura = LocalDateTime.now
	}
	
	def actualizarMensaje(Mensaje mensaje) {
		val mensajeAActualizar = accederAUnMensaje(mensaje.id)
		mensajeAActualizar.leido = mensaje.leido
	}
	
	def eliminarMensaje(Integer mensajeId) {
		val mensajeAEliminar = accederAUnMensaje(mensajeId)
		mensajesInternos.remove(mensajeAEliminar)
	}
	
	def recibirMail(Mail mail) {
		mails.add(mail)
	}
	
	def crearAccion(Accion accion, Receta receta) {
		if(!receta.esColaborador(this)) {
			throw new Exception("Solo un colaborador puede crear acciones para la receta")
		}
		receta.agregarAccion(accion)
	}

	def ejecutarAcciones(Receta receta) {
		if (!receta.esAutor(this)) {
			throw new Exception("Solo el autor puede ejecutar acciones sobre la receta")
		}
		receta.ejecutarAcciones
	}
	
}

enum Rutina {
	LEVE,
	NADA,
	MEDIANO,
	INTENSIVO,
	ACTIVO
}
