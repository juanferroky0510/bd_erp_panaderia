-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema erp_panaderia
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema erp_panaderia
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `erp_panaderia` DEFAULT CHARACTER SET utf8 ;
USE `erp_panaderia` ;

-- -----------------------------------------------------
-- Table `erp_panaderia`.`proveedores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`proveedores` (
  `idProveedor` INT NOT NULL AUTO_INCREMENT,
  `nombreProv` VARCHAR(100) NULL,
  `correoProv` VARCHAR(50) NULL,
  `telefonoProv` VARCHAR(10) NULL,
  `rfc` VARCHAR(13) NULL,
  `pais` VARCHAR(50) NULL,
  `estado` VARCHAR(50) NULL,
  `municipio` VARCHAR(50) NULL,
  `calle` VARCHAR(50) NULL,
  `tiempoEntregaDias` INT NULL,
  `estadoProveedor` VARCHAR(45) NULL DEFAULT 'ACTIVO',
  PRIMARY KEY (`idProveedor`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`puestos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`puestos` (
  `idPuesto` INT NOT NULL AUTO_INCREMENT,
  `nombrePuesto` VARCHAR(45) NULL,
  `descripcionFunciones` VARCHAR(100) NULL,
  PRIMARY KEY (`idPuesto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`turnos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`turnos` (
  `idTurno` INT NOT NULL AUTO_INCREMENT,
  `nombreTurno` VARCHAR(45) NULL,
  `horaInicio` TIME NULL,
  `horaFin` TIME NULL,
  `toleranciaMinutos` INT NULL,
  PRIMARY KEY (`idTurno`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`empleados`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`empleados` (
  `idEmpleado` INT NOT NULL AUTO_INCREMENT,
  `nombreEmpleado` VARCHAR(45) NULL,
  `apellidoPaterno` VARCHAR(45) NULL,
  `apellidoMaterno` VARCHAR(45) NULL,
  `correoEmpleado` VARCHAR(45) NULL,
  `contrasena` VARCHAR(45) NULL,
  `telefonoEmpleado` VARCHAR(10) NULL,
  `fechaContratacion` DATE NULL,
  `salario` DECIMAL(10,2) NULL,
  `estado` VARCHAR(45) NULL DEFAULT 'ACTIVO',
  `puestos_idPuesto` INT NOT NULL,
  `turnos_idTurno` INT NOT NULL,
  PRIMARY KEY (`idEmpleado`, `puestos_idPuesto`, `turnos_idTurno`),
  INDEX `fk_empleados_puestos1_idx` (`puestos_idPuesto` ASC) VISIBLE,
  INDEX `fk_empleados_turnos1_idx` (`turnos_idTurno` ASC) VISIBLE,
  CONSTRAINT `fk_empleados_puestos1`
    FOREIGN KEY (`puestos_idPuesto`)
    REFERENCES `erp_panaderia`.`puestos` (`idPuesto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_empleados_turnos1`
    FOREIGN KEY (`turnos_idTurno`)
    REFERENCES `erp_panaderia`.`turnos` (`idTurno`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`compras`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`compras` (
  `idCompra` INT NOT NULL AUTO_INCREMENT,
  `fechaCompra` DATETIME NULL,
  `estado` VARCHAR(45) NULL,
  `totalCompra` DECIMAL(10,2) NULL,
  `empleados_idEmpleado` INT NOT NULL,
  PRIMARY KEY (`idCompra`, `empleados_idEmpleado`),
  INDEX `fk_compras_empleados1_idx` (`empleados_idEmpleado` ASC) VISIBLE,
  CONSTRAINT `fk_compras_empleados1`
    FOREIGN KEY (`empleados_idEmpleado`)
    REFERENCES `erp_panaderia`.`empleados` (`idEmpleado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`inventario` (
  `idinventario` INT NOT NULL AUTO_INCREMENT,
  `fechaIngreso` DATETIME NULL,
  `fechaCaducidad` DATE NULL,
  `cantidadInicial` DECIMAL(10,3) NULL,
  `cantidadDisponible` DECIMAL(10,3) NULL,
  `costoUnitario` DECIMAL(10,2) NULL,
  `compras_idCompra` INT NOT NULL,
  PRIMARY KEY (`idinventario`, `compras_idCompra`),
  INDEX `fk_inventario_compras1_idx` (`compras_idCompra` ASC) VISIBLE,
  CONSTRAINT `fk_inventario_compras1`
    FOREIGN KEY (`compras_idCompra`)
    REFERENCES `erp_panaderia`.`compras` (`idCompra`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`unidadesMedida`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`unidadesMedida` (
  `idUnidadMedida` INT NOT NULL AUTO_INCREMENT,
  `nombreUnidad` VARCHAR(45) NULL,
  `abreviatura` VARCHAR(10) NULL,
  PRIMARY KEY (`idUnidadMedida`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`productos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`productos` (
  `idProducto` INT NOT NULL AUTO_INCREMENT,
  `nombreProducto` VARCHAR(45) NULL,
  `descripcionProducto` VARCHAR(100) NULL,
  `tipoProducto` VARCHAR(45) NULL,
  `estado` VARCHAR(45) NULL DEFAULT 'ACTIVO',
  `stockMinimo` INT NULL,
  `costoPromedio` DECIMAL(10,2) NULL,
  `precioVenta` DECIMAL(10,2) NULL,
  `unidadesMedida_idUnidadMedida` INT NOT NULL,
  PRIMARY KEY (`idProducto`, `unidadesMedida_idUnidadMedida`),
  INDEX `fk_productos_unidadesMedida1_idx` (`unidadesMedida_idUnidadMedida` ASC) VISIBLE,
  CONSTRAINT `fk_productos_unidadesMedida1`
    FOREIGN KEY (`unidadesMedida_idUnidadMedida`)
    REFERENCES `erp_panaderia`.`unidadesMedida` (`idUnidadMedida`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`productoOfrecido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`productoOfrecido` (
  `proveedores_idProveedor` INT NOT NULL,
  `productos_idProducto` INT NOT NULL,
  PRIMARY KEY (`proveedores_idProveedor`, `productos_idProducto`),
  INDEX `fk_proveedores_has_productos_productos1_idx` (`productos_idProducto` ASC) VISIBLE,
  INDEX `fk_proveedores_has_productos_proveedores1_idx` (`proveedores_idProveedor` ASC) VISIBLE,
  CONSTRAINT `fk_proveedores_has_productos_proveedores1`
    FOREIGN KEY (`proveedores_idProveedor`)
    REFERENCES `erp_panaderia`.`proveedores` (`idProveedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_proveedores_has_productos_productos1`
    FOREIGN KEY (`productos_idProducto`)
    REFERENCES `erp_panaderia`.`productos` (`idProducto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`movimientosInventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`movimientosInventario` (
  `idMovimientoInventario` INT NOT NULL AUTO_INCREMENT,
  `tipoMovimiento` VARCHAR(45) NULL,
  `cantidad` DECIMAL(10,3) NULL,
  `costoAplicado` DECIMAL(10,2) NULL,
  `fechaActualizacion` DATETIME NULL,
  `causaMerma` VARCHAR(100) NULL,
  `empleados_idEmpleado` INT NOT NULL,
  `inventario_idinventario` INT NOT NULL,
  PRIMARY KEY (`idMovimientoInventario`, `empleados_idEmpleado`, `inventario_idinventario`),
  INDEX `fk_movimientosInventario_empleados1_idx` (`empleados_idEmpleado` ASC) VISIBLE,
  INDEX `fk_movimientosInventario_inventario1_idx` (`inventario_idinventario` ASC) VISIBLE,
  CONSTRAINT `fk_movimientosInventario_empleados1`
    FOREIGN KEY (`empleados_idEmpleado`)
    REFERENCES `erp_panaderia`.`empleados` (`idEmpleado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_movimientosInventario_inventario1`
    FOREIGN KEY (`inventario_idinventario`)
    REFERENCES `erp_panaderia`.`inventario` (`idinventario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`recetas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`recetas` (
  `idRecetas` INT NOT NULL AUTO_INCREMENT,
  `nombreReceta` VARCHAR(45) NULL,
  `estado` VARCHAR(45) NULL DEFAULT 'ACTIVO',
  PRIMARY KEY (`idRecetas`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`detallesReceta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`detallesReceta` (
  `recetas_idRecetas` INT NOT NULL,
  `productos_idProducto` INT NOT NULL,
  `cantidadNecesaria` DECIMAL(10,3) NULL,
  PRIMARY KEY (`recetas_idRecetas`, `productos_idProducto`),
  INDEX `fk_recetas_has_productos_productos1_idx` (`productos_idProducto` ASC) VISIBLE,
  INDEX `fk_recetas_has_productos_recetas1_idx` (`recetas_idRecetas` ASC) VISIBLE,
  CONSTRAINT `fk_recetas_has_productos_recetas1`
    FOREIGN KEY (`recetas_idRecetas`)
    REFERENCES `erp_panaderia`.`recetas` (`idRecetas`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_recetas_has_productos_productos1`
    FOREIGN KEY (`productos_idProducto`)
    REFERENCES `erp_panaderia`.`productos` (`idProducto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`ordenesProduccion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`ordenesProduccion` (
  `idOrdenProduccion` INT NOT NULL AUTO_INCREMENT,
  `fechaProduccion` DATETIME NULL,
  `cantidadPlaneada` DECIMAL(10,3) NULL,
  `cantidadProducida` DECIMAL(10,3) NULL,
  `estado` VARCHAR(45) NULL DEFAULT 'PENDIENTE',
  `recetas_idRecetas` INT NOT NULL,
  `empleados_idEmpleado` INT NOT NULL,
  PRIMARY KEY (`idOrdenProduccion`, `recetas_idRecetas`, `empleados_idEmpleado`),
  INDEX `fk_ordenesProduccion_recetas1_idx` (`recetas_idRecetas` ASC) VISIBLE,
  INDEX `fk_ordenesProduccion_empleados1_idx` (`empleados_idEmpleado` ASC) VISIBLE,
  CONSTRAINT `fk_ordenesProduccion_recetas1`
    FOREIGN KEY (`recetas_idRecetas`)
    REFERENCES `erp_panaderia`.`recetas` (`idRecetas`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ordenesProduccion_empleados1`
    FOREIGN KEY (`empleados_idEmpleado`)
    REFERENCES `erp_panaderia`.`empleados` (`idEmpleado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`asistencias`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`asistencias` (
  `idAsistencia` INT NOT NULL AUTO_INCREMENT,
  `horaEntrada` DATETIME NULL,
  `horaSalida` DATETIME NULL,
  `minutosRetardo` INT NULL,
  `horasTrabajadas` INT NULL,
  `estadoAsistencia` VARCHAR(45) NULL,
  `observaciones` VARCHAR(100) NULL,
  `empleados_idEmpleado` INT NOT NULL,
  PRIMARY KEY (`idAsistencia`, `empleados_idEmpleado`),
  INDEX `fk_asistencias_empleados1_idx` (`empleados_idEmpleado` ASC) VISIBLE,
  CONSTRAINT `fk_asistencias_empleados1`
    FOREIGN KEY (`empleados_idEmpleado`)
    REFERENCES `erp_panaderia`.`empleados` (`idEmpleado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `erp_panaderia`.`detallesCompras`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `erp_panaderia`.`detallesCompras` (
  `productos_idProducto` INT NOT NULL,
  `compras_idCompra` INT NOT NULL,
  `costoUnitario` DECIMAL(10,2) NULL,
  `cantidad` DECIMAL(10,3) NULL,
  `subtotal` DECIMAL(10,2) NULL,
  PRIMARY KEY (`productos_idProducto`, `compras_idCompra`),
  INDEX `fk_productos_has_compras_compras1_idx` (`compras_idCompra` ASC) VISIBLE,
  INDEX `fk_productos_has_compras_productos1_idx` (`productos_idProducto` ASC) VISIBLE,
  CONSTRAINT `fk_productos_has_compras_productos1`
    FOREIGN KEY (`productos_idProducto`)
    REFERENCES `erp_panaderia`.`productos` (`idProducto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_productos_has_compras_compras1`
    FOREIGN KEY (`compras_idCompra`)
    REFERENCES `erp_panaderia`.`compras` (`idCompra`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;