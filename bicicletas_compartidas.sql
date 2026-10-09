-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-10-2026 a las 21:51:16
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bicicletas_compartidas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bicicleta`
--

CREATE TABLE `bicicleta` (
  `nro_serie` varchar(30) NOT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'disponible',
  `codigo_estacion` varchar(10) NOT NULL
) ;

--
-- Disparadores `bicicleta`
--
DELIMITER $$
CREATE TRIGGER `trg_bicicleta_capacidad_ins` BEFORE INSERT ON `bicicleta` FOR EACH ROW BEGIN
    DECLARE v_capacidad INT;
    DECLARE v_actuales  INT;

    SELECT capacidad_maxima INTO v_capacidad
      FROM estacion WHERE codigo_estacion = NEW.codigo_estacion;
    SELECT COUNT(*) INTO v_actuales
      FROM bicicleta WHERE codigo_estacion = NEW.codigo_estacion;

    IF v_actuales + 1 > v_capacidad THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La estación alcanzó su capacidad máxima';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_bicicleta_capacidad_upd` BEFORE UPDATE ON `bicicleta` FOR EACH ROW BEGIN
    DECLARE v_capacidad INT;
    DECLARE v_actuales  INT;

    IF NEW.codigo_estacion <> OLD.codigo_estacion THEN
        SELECT capacidad_maxima INTO v_capacidad
          FROM estacion WHERE codigo_estacion = NEW.codigo_estacion;
        SELECT COUNT(*) INTO v_actuales
          FROM bicicleta WHERE codigo_estacion = NEW.codigo_estacion;

        IF v_actuales + 1 > v_capacidad THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La estación alcanzó su capacidad máxima';
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estacion`
--

CREATE TABLE `estacion` (
  `codigo_estacion` varchar(10) NOT NULL,
  `direccion` varchar(150) NOT NULL,
  `capacidad_maxima` int(11) NOT NULL
) ;

--
-- Volcado de datos para la tabla `estacion`
--

INSERT INTO `estacion` (`codigo_estacion`, `direccion`, `capacidad_maxima`) VALUES
('A1', 'Hirigoyen 300', 20),
('A2', 'Urquiza 620', 20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mantenimientos`
--

CREATE TABLE `mantenimientos` (
  `id` int(11) NOT NULL,
  `codigo_estacion` varchar(20) NOT NULL,
  `legajo_operario` varchar(20) NOT NULL,
  `fecha` datetime NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `operarios`
--

CREATE TABLE `operarios` (
  `legajo` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `dni` varchar(12) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`dni`, `nombre`) VALUES
('35987456', 'Pedro Cerezo'),
('39632741', 'Gaston Cerezo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_medio_pago`
--

CREATE TABLE `usuario_medio_pago` (
  `dni` varchar(10) NOT NULL,
  `numero_tarjeta` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `viaje`
--

CREATE TABLE `viaje` (
  `id_viaje` int(11) NOT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime DEFAULT NULL,
  `dni_usuario` varchar(10) NOT NULL,
  `numero_serie_bici` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `bicicleta`
--
ALTER TABLE `bicicleta`
  ADD PRIMARY KEY (`nro_serie`),
  ADD KEY `ix_bicicleta_estacion_estado` (`codigo_estacion`,`estado`);

--
-- Indices de la tabla `estacion`
--
ALTER TABLE `estacion`
  ADD PRIMARY KEY (`codigo_estacion`),
  ADD UNIQUE KEY `uq_estacion_direccion` (`direccion`);

--
-- Indices de la tabla `mantenimientos`
--
ALTER TABLE `mantenimientos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_mantenimiento_estacion` (`codigo_estacion`),
  ADD KEY `fk_mantenimiento_operario` (`legajo_operario`);

--
-- Indices de la tabla `operarios`
--
ALTER TABLE `operarios`
  ADD PRIMARY KEY (`legajo`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`dni`);

--
-- Indices de la tabla `usuario_medio_pago`
--
ALTER TABLE `usuario_medio_pago`
  ADD PRIMARY KEY (`dni`,`numero_tarjeta`);

--
-- Indices de la tabla `viaje`
--
ALTER TABLE `viaje`
  ADD PRIMARY KEY (`id_viaje`),
  ADD KEY `fk_viaje_usuario` (`dni_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `mantenimientos`
--
ALTER TABLE `mantenimientos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `viaje`
--
ALTER TABLE `viaje`
  MODIFY `id_viaje` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bicicleta`
--
ALTER TABLE `bicicleta`
  ADD CONSTRAINT `fk_bicicleta_estacion` FOREIGN KEY (`codigo_estacion`) REFERENCES `estacion` (`codigo_estacion`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `mantenimientos`
--
ALTER TABLE `mantenimientos`
  ADD CONSTRAINT `fk_mantenimiento_operario` FOREIGN KEY (`legajo_operario`) REFERENCES `operarios` (`legajo`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario_medio_pago`
--
ALTER TABLE `usuario_medio_pago`
  ADD CONSTRAINT `fk_medio_usuario` FOREIGN KEY (`dni`) REFERENCES `usuario` (`dni`) ON DELETE CASCADE;

--
-- Filtros para la tabla `viaje`
--
ALTER TABLE `viaje`
  ADD CONSTRAINT `fk_viaje_usuario` FOREIGN KEY (`dni_usuario`) REFERENCES `usuario` (`dni`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
