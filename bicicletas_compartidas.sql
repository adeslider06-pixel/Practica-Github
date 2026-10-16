-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-10-2026 a las 21:33:09
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
-- Volcado de datos para la tabla `bicicleta`
--

INSERT INTO `bicicleta` (`nro_serie`, `estado`, `codigo_estacion`) VALUES
('A01', 'disponible', 'A1'),
('A05', 'disponible', 'A1'),
('A03', 'En mantenimiento', 'A1'),
('A02', 'disponible', 'B1'),
('A04', 'en uso', 'B1');

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
('A1', 'Av. San Martin 253', 20),
('B1', 'Av. San Martin', 20),
('B2', 'Av. Velazco 530', 20);

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

--
-- Volcado de datos para la tabla `mantenimientos`
--

INSERT INTO `mantenimientos` (`id`, `codigo_estacion`, `legajo_operario`, `fecha`, `descripcion`) VALUES
(3, 'A1', '25', '2026-10-16 14:00:00', 'Revisión general de la estación'),
(4, 'A1', '25', '2026-10-02 14:00:00', 'Cambio de cubiertas'),
(5, 'A2', '26', '2026-10-02 14:00:00', 'Limpieza de la estacion '),
(6, 'A3', '26', '2026-10-06 14:00:00', 'Pintura de señalización.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `operarios`
--

CREATE TABLE `operarios` (
  `legajo` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `operarios`
--

INSERT INTO `operarios` (`legajo`, `nombre`) VALUES
('25', 'Jose Gonzales '),
('26', 'Pablo Romero '),
('27', 'Juan Perez ');

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
('37987458', 'Nombre Apellido'),
('39632741', 'Gaston Cerezo'),
('43587912', 'Gaston Paez'),
('50417867', 'Santiago Carril');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_medio_pago`
--

CREATE TABLE `usuario_medio_pago` (
  `dni` varchar(10) NOT NULL,
  `numero_tarjeta` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuario_medio_pago`
--

INSERT INTO `usuario_medio_pago` (`dni`, `numero_tarjeta`) VALUES
('35987456', 'xxxxxxxxxxxxxxxxx'),
('39632741', 'xxxxxxxxxxxxxxxxx'),
('43587912', 'xxxxxxxxxxxxxxxxx');

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
-- Volcado de datos para la tabla `viaje`
--

INSERT INTO `viaje` (`id_viaje`, `fecha_inicio`, `fecha_fin`, `dni_usuario`, `numero_serie_bici`) VALUES
(1, '2026-10-16 20:45:48', '2026-10-13 15:45:49', '35987456', ''),
(5, '2026-10-02 15:00:00', '2026-10-02 15:45:49', '35987456', 'A01'),
(6, '2026-10-02 15:00:00', '2026-10-02 15:45:49', '37987458', 'A01');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `viaje`
--
ALTER TABLE `viaje`
  MODIFY `id_viaje` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
