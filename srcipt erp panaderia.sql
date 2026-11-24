USE `erp_panaderia`;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- PROCEDIMIENTOS ALMACENADOS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- -----------------------------------------------------
-- validar usuarios
-- -----------------------------------------------------
USE `erp_panaderia`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `spValidarAcceso`$$

CREATE PROCEDURE `spValidarAcceso` (
    IN p_correo VARCHAR(45),
    IN p_contrasena VARCHAR(255)
)
BEGIN
    DECLARE v_idEmpleado INT;
    DECLARE v_nombreCompleto VARCHAR(150);
    DECLARE v_correoEmpleado VARCHAR(45);
    DECLARE v_estado VARCHAR(45);
    DECLARE v_idPuesto INT;
    DECLARE v_rol VARCHAR(45);
    DECLARE v_idTurno INT;
    DECLARE v_nombreTurno VARCHAR(45);
    DECLARE v_horaInicio TIME;
    DECLARE v_horaFin TIME;
    DECLARE v_tolerancia INT;
    DECLARE v_horaInicioPermitida TIME;
    DECLARE v_horaActual TIME;
    DECLARE v_enHorario BOOLEAN DEFAULT FALSE;

    -- 1. Buscar al empleado con sus datos de puesto y turno
    SELECT 
        e.`idEmpleado`,
        CONCAT(e.`nombreEmpleado`, ' ', e.`apellidoPaterno`, ' ', e.`apellidoMaterno`),
        e.`correoEmpleado`,
        e.`estado`,
        p.`idPuesto`,
        p.`nombrePuesto`,
        t.`idTurno`,
        t.`nombreTurno`,
        t.`horaInicio`,
        t.`horaFin`,
        IFNULL(t.`toleranciaMinutos`, 0)
    INTO 
        v_idEmpleado, v_nombreCompleto, v_correoEmpleado, v_estado,
        v_idPuesto, v_rol, v_idTurno, v_nombreTurno,
        v_horaInicio, v_horaFin, v_tolerancia
    FROM `empleados` e
    INNER JOIN `puestos` p ON e.`puestos_idPuesto` = p.`idPuesto`
    INNER JOIN `turnos` t ON e.`turnos_idTurno` = t.`idTurno`
    WHERE e.`correoEmpleado` = p_correo
      AND e.`contrasena` = p_contrasena
    LIMIT 1;

    -- 2. Validar existencia y estado ACTIVO
    IF v_idEmpleado IS NULL THEN
        SELECT '0' AS ban, 'Correo o contraseña incorrectos.' AS msg;

    ELSEIF v_estado <> 'ACTIVO' THEN
        SELECT '0' AS ban, 'Tu usuario se encuentra dado de baja. Contacta al Administrador.' AS msg;

    ELSE
        -- 3. Calcular hora actual y hora de entrada permitida (restando toleranciaMinutos)
        SET v_horaActual = CURTIME();
        SET v_horaInicioPermitida = SUBTIME(v_horaInicio, SEC_TO_TIME(v_tolerancia * 60));

        -- 4. Evaluar si el turno es normal (mismo día) o nocturno (cruza medianoche)
        IF v_horaInicioPermitida <= v_horaFin THEN
            -- Turno normal (Ej. Matutino 05:50:00 a 20:00:00)
            IF v_horaActual >= v_horaInicioPermitida AND v_horaActual <= v_horaFin THEN
                SET v_enHorario = TRUE;
            END IF;
        ELSE
            -- Turno nocturno que cruza medianoche (Ej. 21:50:00 a 05:59:59)
            IF v_horaActual >= v_horaInicioPermitida OR v_horaActual <= v_horaFin THEN
                SET v_enHorario = TRUE;
            END IF;
        END IF;

        -- 5. Excepción: Si es Administrador entra sin importar horario; si no, debe estar en turno
        IF v_rol = 'Administrador' OR v_enHorario = TRUE THEN
            SELECT 
                '1' AS ban,
                'Acceso concedido.' AS msg,
                v_idEmpleado AS idEmpleado,
                v_nombreCompleto AS nombreCompleto,
                v_correoEmpleado AS correoEmpleado,
                v_idPuesto AS idPuesto,
                v_rol AS rol,
                v_idTurno AS idTurno,
                v_nombreTurno AS nombreTurno;
        ELSE
            SELECT 
                '0' AS ban,
                CONCAT(
                    'Acceso denegado: estás fuera de tu turno ', v_nombreTurno,
                    ' (', TIME_FORMAT(v_horaInicio, '%H:%i'), ' - ', TIME_FORMAT(v_horaFin, '%H:%i'), ').'
                ) AS msg;
        END IF;
    END IF;
END$$

DELIMITER ;

-- Ejemplos de uso
-- 1. Insertar puestos (roles del sistema)
INSERT INTO `puestos` (`nombrePuesto`, `descripcionFunciones`) VALUES 
('Administrador', 'Control total del sistema'),
('Almacenista', 'Encargado de recibir y controlar materias primas'),
('Panadero', 'Encargado de crear ordenes de producción y recetas'),
('Recursos Humanos', 'Encargado de administrar al personal');
select * from puestos;

-- 2. Insertar turnos
INSERT INTO `turnos` (`nombreTurno`, `horaInicio`, `horaFin`, `toleranciaMinutos`) VALUES 
('Matutino', '06:00:00', '13:59:59', 10),
('Vespertino', '14:00:00', '21:59:59', 10),
('Nocturno', '22:00:00', '05:59:59', 10);
select * from turnos;

-- 3. Insertar empleados de prueba (ajusta los IDs 1 y 2 si ya tenías registros previos)
INSERT INTO `empleados` (
    `nombreEmpleado`, `apellidoPaterno`, `apellidoMaterno`, 
    `correoEmpleado`, `contrasena`, `telefonoEmpleado`, 
    `fechaContratacion`, `salario`, `estado`, 
    `puestos_idPuesto`, `turnos_idTurno`
) VALUES 
(
    'Juan Fernando', 'Ortega', 'Olvera', 
    'jfoo@gmail.com', 'admin123', '7719500321', 
    '2026-11-17', 15000.00, 'ACTIVO', 
    1, 1
),
(
    'Arely', 'Tellez', 'Salas', 
    'ats@gmail.com', 'rh123', '7717654321', 
    '2026-11-17', 9500.00, 'ACTIVO', 
    4, 2
),
(
    'Derek', 'Vargas', 'Meneses', 
    'dvm@gmail.com', 'pan123', '7715678934', 
    '2026-11-17', 9500.00, 'BAJA', 
    3, 3
);
select * from empleados;


-- Prueba 1: Acceso correcto (debe regresar ban = '1' y los datos del usuario)
CALL spValidarAcceso('jfoo@gmail.com', 'admin123');
CALL spValidarAcceso('ats@gmail.com', 'rh123');
-- Prueba 2: Contraseña incorrecta (debe regresar ban = '0')
CALL spValidarAcceso('jfoo@gmail.com', 'clave_erronea');
-- Prueba 3: Empleado dado de baja (debe regresar ban = '0' aunque la clave sea correcta)
CALL spValidarAcceso('dvm@gmail.com', 'pan123');


-- -----------------------------------------------------
-- insertar proveedor
-- -----------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `spInsertarProveedor`$$

CREATE PROCEDURE `spInsertarProveedor` (
    IN p_idEmpleado INT,
    IN p_nombreProv VARCHAR(100),
    IN p_correoProv VARCHAR(50),
    IN p_telefonoProv VARCHAR(10),
    IN p_rfc VARCHAR(13),
    IN p_pais VARCHAR(50),
    IN p_estado VARCHAR(50),
    IN p_municipio VARCHAR(50),
    IN p_calle VARCHAR(50),
    IN p_tiempoEntregaDias INT
)
BEGIN
    DECLARE v_rol VARCHAR(45);
    DECLARE v_estadoEmpleado VARCHAR(45);

    -- 1. Obtener el rol y estado del empleado que intenta hacer la operación
    SELECT p.`nombrePuesto`, e.`estado`
    INTO v_rol, v_estadoEmpleado
    FROM `empleados` e
    INNER JOIN `puestos` p ON e.`puestos_idPuesto` = p.`idPuesto`
    WHERE e.`idEmpleado` = p_idEmpleado
    LIMIT 1;

    -- 2. Validar existencia, estado ACTIVO y rol autorizado
    IF v_rol IS NULL OR v_estadoEmpleado <> 'ACTIVO' THEN
        SELECT '0' AS ban, 'Usuario no válido o dado de baja. Acceso denegado.' AS msg;

    ELSEIF v_rol NOT IN ('Administrador', 'Recursos Humanos') THEN
        SELECT '0' AS ban, 'No tienes permisos para registrar proveedores (Solo Administrador o Recursos Humanos).' AS msg;

    -- 3. Validar campos obligatorios
    ELSEIF p_nombreProv IS NULL OR TRIM(p_nombreProv) = '' THEN
        SELECT '0' AS ban, 'El nombre del proveedor es obligatorio.' AS msg;

    ELSEIF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        SELECT '0' AS ban, 'El RFC del proveedor es obligatorio.' AS msg;

    -- 4. Validar tiempo de entrega lógico
    ELSEIF p_tiempoEntregaDias IS NULL OR p_tiempoEntregaDias <= 0 THEN
        SELECT '0' AS ban, 'El tiempo de entrega debe ser de al menos 1 día.' AS msg;

    -- 5. Validar que no exista otro proveedor con el mismo RFC
    ELSEIF EXISTS (
        SELECT 1 FROM `proveedores` 
        WHERE UPPER(TRIM(`rfc`)) = UPPER(TRIM(p_rfc))
    ) THEN
        SELECT '0' AS ban, 'Ya existe un proveedor registrado con ese RFC.' AS msg;

    -- 6. Si pasa todas las validaciones, insertar el registro
    ELSE
        INSERT INTO `proveedores` (
            `nombreProv`, `correoProv`, `telefonoProv`, `rfc`,
            `pais`, `estado`, `municipio`, `calle`, `tiempoEntregaDias`
        ) VALUES (
            TRIM(p_nombreProv),
            TRIM(p_correoProv),
            TRIM(p_telefonoProv),
            UPPER(TRIM(p_rfc)),
            TRIM(p_pais),
            TRIM(p_estado),
            TRIM(p_municipio),
            TRIM(p_calle),
            p_tiempoEntregaDias
        );

        -- Devolver ban = '1', mensaje de éxito y el registro recién creado
        SELECT 
            '1' AS ban,
            'Proveedor registrado correctamente.' AS msg;
    END IF;
END$$

DELIMITER ;

-- Prueba 1: ÉXITO con Administrador (idEmpleado = 1)
CALL spInsertarProveedor(
    1,
    'Harinera del Centro S.A. de C.V.',
    'ventas@harineracentro.com',
    '7711112233',
    'HCE980512AB1',
    'México',
    'Hidalgo',
    'Pachuca de Soto',
    'Blvd. Felipe Ángeles 1402',
    2
);

-- Prueba 2: ÉXITO con Recursos Humanos (idEmpleado = 2)
CALL spInsertarProveedor(
    2,
    'Lácteos y Mantequillas Real',
    'contacto@lacteosreal.mx',
    '7714445566',
    'LMR051120XY9',
    'México',
    'Hidalgo',
    'Tulancingo',
    'Av. Juárez 310',
    1
);

-- Prueba 3: RECHAZO por RFC duplicado (debe regresar ban = '0')
CALL spInsertarProveedor(
    1,
    'Harinera Duplicada',
    'otro@correo.com',
    '7719998877',
    'HCE980512AB1',
    'México',
    'Hidalgo',
    'Pachuca',
    'Calle 1',
    3
);

-- Prueba 4: RECHAZO por rol no autorizado / usuario dado de baja (idEmpleado = 3)
CALL spInsertarProveedor(
    3,
    'Levaduras Express',
    'info@levaduras.com',
    '7712223344',
    'LEX120101ZZ3',
    'México',
    'Hidalgo',
    'Mineral de la Reforma',
    'Av. Universidad 50',
    2
);

select * from proveedores;

-- -----------------------------------------------------
-- actualizar proveedor
-- -----------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `spActualizarProveedor`$$

CREATE PROCEDURE `spActualizarProveedor` (
    IN p_idEmpleado INT,
    IN p_idProveedor INT,
    IN p_nombreProv VARCHAR(100),
    IN p_correoProv VARCHAR(50),
    IN p_telefonoProv VARCHAR(10),
    IN p_rfc VARCHAR(13),
    IN p_pais VARCHAR(50),
    IN p_estado VARCHAR(50),
    IN p_municipio VARCHAR(50),
    IN p_calle VARCHAR(50),
    IN p_tiempoEntregaDias INT,
    IN p_estadoProveedor VARCHAR(45)
)
BEGIN
    DECLARE v_rol VARCHAR(45);
    DECLARE v_estadoEmpleado VARCHAR(45);

    -- 1. Obtener el rol y estado del empleado que solicita la actualización
    SELECT p.`nombrePuesto`, e.`estado`
    INTO v_rol, v_estadoEmpleado
    FROM `empleados` e
    INNER JOIN `puestos` p ON e.`puestos_idPuesto` = p.`idPuesto`
    WHERE e.`idEmpleado` = p_idEmpleado
    LIMIT 1;

    -- 2. Validar existencia, estado ACTIVO y rol autorizado
    IF v_rol IS NULL OR v_estadoEmpleado <> 'ACTIVO' THEN
        SELECT '0' AS ban, 'Usuario no válido o dado de baja. Acceso denegado.' AS msg;

    ELSEIF v_rol NOT IN ('Administrador', 'Recursos Humanos') THEN
        SELECT '0' AS ban, 'No tienes permisos para actualizar proveedores (Solo Administrador o Recursos Humanos).' AS msg;

    -- 3. Validar que el proveedor a actualizar exista
    ELSEIF NOT EXISTS (
        SELECT 1 FROM `proveedores` WHERE `idProveedor` = p_idProveedor
    ) THEN
        SELECT '0' AS ban, 'El proveedor seleccionado no existe.' AS msg;

    -- 4. Validar campos obligatorios
    ELSEIF p_nombreProv IS NULL OR TRIM(p_nombreProv) = '' THEN
        SELECT '0' AS ban, 'El nombre del proveedor es obligatorio.' AS msg;

    ELSEIF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        SELECT '0' AS ban, 'El RFC del proveedor es obligatorio.' AS msg;

    -- 5. Validar tiempo de entrega lógico
    ELSEIF p_tiempoEntregaDias IS NULL OR p_tiempoEntregaDias <= 0 THEN
        SELECT '0' AS ban, 'El tiempo de entrega debe ser de al menos 1 día.' AS msg;

    -- 6. Validar que el RFC no esté asignado a OTRO proveedor
    ELSEIF EXISTS (
        SELECT 1 FROM `proveedores`
        WHERE UPPER(TRIM(`rfc`)) = UPPER(TRIM(p_rfc))
          AND `idProveedor` <> p_idProveedor
    ) THEN
        SELECT '0' AS ban, 'Ya existe otro proveedor registrado con ese RFC.' AS msg;

    -- 7. Ejecutar la actualización
    ELSE
        UPDATE `proveedores`
        SET
            `nombreProv` = TRIM(p_nombreProv),
            `correoProv` = TRIM(p_correoProv),
            `telefonoProv` = TRIM(p_telefonoProv),
            `rfc` = UPPER(TRIM(p_rfc)),
            `pais` = TRIM(p_pais),
            `estado` = TRIM(p_estado),
            `municipio` = TRIM(p_municipio),
            `calle` = TRIM(p_calle),
            `tiempoEntregaDias` = p_tiempoEntregaDias,
            `estadoProveedor` = p_estadoProveedor
        WHERE `idProveedor` = p_idProveedor;

        -- Devolver ban = '1', mensaje de confirmación y los datos actualizados
        SELECT 
            '1' AS ban,
            'Proveedor actualizado correctamente.' AS msg;
    END IF;
END$$

DELIMITER ;

-- Prueba 1: ÉXITO actualizando el proveedor 1 con Administrador (idEmpleado = 1)
CALL spActualizarProveedor(
    1,
    1,
    'Harinera del Centro S.A. de C.V.',
    'atencion@harineracentro.com',
    '7711119999',
    'HCE980512AB1',
    'México',
    'Hidalgo',
    'Pachuca de Soto',
    'Blvd. Felipe Ángeles 1402 Int. B',
    1,
    'ACTIVO'
);

-- Prueba 2: RECHAZO por proveedor inexistente (idProveedor = 999)
CALL spActualizarProveedor(
    2,
    999,
    'Proveedor Fantasma',
    'test@test.com',
    '7710000000',
    'PFA010101AA1',
    'México',
    'Hidalgo',
    'Pachuca',
    'Calle 1',
    2,
    'ACTIVO'
);

-- Prueba 3: RECHAZO por empleado sin permiso / dado de baja (idEmpleado = 3)
CALL spActualizarProveedor(
    3,
    1,
    'Intento No Autorizado',
    'no@valido.com',
    '7710000000',
    'HCE980512AB1',
    'México',
    'Hidalgo',
    'Pachuca',
    'Calle 1',
    2,
    'ACTIVO'
);

select * from proveedores;


-- -----------------------------------------------------
-- buscar un proveedor
-- -----------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `spBuscarProveedor`$$

CREATE PROCEDURE `spBuscarProveedor` (
    IN p_busqueda VARCHAR(100)
)
BEGIN
    -- 1. Validar que el criterio de búsqueda no venga vacío
    IF p_busqueda IS NULL OR TRIM(p_busqueda) = '' THEN
        SELECT '0' AS ban, 'Ingresa un nombre, RFC o ID para buscar.' AS msg;

    -- 2. Validar si existen coincidencias en la vista vwRptProveedor
    ELSEIF NOT EXISTS (
        SELECT 1 
        FROM `vwRptProveedor`
        WHERE `nombreProv` LIKE CONCAT('%', TRIM(p_busqueda), '%')
           OR `rfc` LIKE CONCAT('%', TRIM(p_busqueda), '%')
           OR CAST(`idProveedor` AS CHAR) = TRIM(p_busqueda)
    ) THEN
        SELECT '0' AS ban, CONCAT('No se encontraron proveedores con "', TRIM(p_busqueda), '".') AS msg;

    -- 3. Devolver ban = '1' junto con los registros encontrados
    ELSE
        SELECT 
            '1' AS ban,
            'Proveedores encontrados.' AS msg,
            `idProveedor`,
            `nombreProv`,
            `correoProv`,
            `telefonoProv`,
            `rfc`,
            `direccion`,
            `tiempoEntregaDias`,
            `estadoProveedor`
        FROM `vwRptProveedor`
        WHERE `nombreProv` LIKE CONCAT('%', TRIM(p_busqueda), '%')
           OR `rfc` LIKE CONCAT('%', TRIM(p_busqueda), '%')
           OR CAST(`idProveedor` AS CHAR) = TRIM(p_busqueda);
    END IF;
END$$

DELIMITER ;


-- Buscar por parte del nombre
CALL spBuscarProveedor('harinera');

-- Buscar por RFC
CALL spBuscarProveedor('lmr');

-- Buscar por ID
CALL spBuscarProveedor('4');

-- Buscar algo que no existe (debe devolver ban = '0')
CALL spBuscarProveedor('ProveedorInexistente');

select * from vwRptProveedor;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- VISTAS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- -----------------------------------------------------
-- reporte proveedor
-- -----------------------------------------------------
CREATE OR REPLACE VIEW `vwRptProveedor` AS
SELECT 
    `idProveedor`,
    `nombreProv`,
    `correoProv`,
    `telefonoProv`,
    `rfc`,
    CONCAT_WS(', ', 
        NULLIF(TRIM(`calle`), ''), 
        NULLIF(TRIM(`municipio`), ''), 
        NULLIF(TRIM(`estado`), ''), 
        NULLIF(TRIM(`pais`), '')
    ) AS `direccion`,
    `tiempoEntregaDias`,
    `estadoProveedor`
FROM `proveedores`
ORDER BY `estadoProveedor` ASC, `nombreProv` ASC;

select * from vwRptProveedor;




