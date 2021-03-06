#' Computes support points of the Lorenz curve of a given numeric vector.
#'
#' This function is the initial point to draw a Lorenz curve. It computes the
#' support points of the curve. Call \code{autoplot} on the result object to
#' actually draw the curve.
#'
#' @param x [\code{numeric}]\cr
#'   Numeric source vector with measured quantities.
#' @return [\code{list}]
#'   List containing
#'   \describe{
#'   \item{source [\code{numeric}]}{the source vector.}
#'   \item{data [\code{data.frame}]}{the data frame \pkg{ggplot2} was feeded to produce the Lorenz curve.}
#'   }
#' @export
#' @examples
#' x = abs(rnorm(30, mean = 50, sd = 20))
#' lor = locu(x)
#' print(head(lor$data))
#' print(autoplot(lor, highlight.below.curve = TRUE))
locu = function(x) {
  assertNumeric(x, min.len = 2L, lower = 0L, any.missing = FALSE)
  ggdata = getLorenzCurveDataPoints(x)

  return(structure(list(
    source = x,
    data = ggdata),
    class = "locu"))
}

#' Actually draws the Lorenz curve.
#'
#' @param object [\code{\link{locu}}]\cr
#'   Object of type \code{\link{locu}}.
#' @param xlab [\code{character}]\cr
#'   Label for the x-axis of the Lorenz curve plot. Default is x.
#' @param ylab [\code{character}]\cr
#'   Label for the y-axis of the Lorenz curve plot. Default is y.
#' @param main [\code{character}]\cr
#'   Plot title. Initialized by default to "Lorenz curve".
#' @param highlight.below.curve [\code{logical(1)}]\cr
#'   If \code{TRUE}, the area in between the x-axis and the Lorenz curve is
#'   highlighed, otherwise not.
#' @param highlight.below.curve.alpha [\code{numeric(1)}]\cr
#'   Numeric value in range [0,1] indicating whether the polygon is opaque or (semi)transparent.
#' @param highlight.below.curve.fillcolor [\code{character}]\cr
#'   Color given by one of the build-in color names of R.
#' @param highlight.above.curve [\code{logical(1)}]\cr
#'   If \code{TRUE}, the area in between the Lorenz curve and the line of equality
#'   is highlighed, otherwise not.
#' @param highlight.above.curve.alpha [\code{numeric(1)}]\cr
#'   Numeric value in range [0,1] indicating whether the space between Lorenz curve and
#'   the line of equality is opaque or (semi)transparent.
#' @param highlight.above.curve.fillcolor [\code{character}]\cr
#'   Color given by one of the build-in color names of R.
#' @param point.size [\code{numeric(1)}]\cr
#'   Point size.
#' @param ... [\code{list}]\cr
#'   Further params.
#' @return
#'   Object of type \code{\link[ggplot2]{ggplot}}.
#' @export autoplot.locu
#' @method autoplot locu
autoplot.locu = function(object,
  xlab = "x", ylab = "y",
  main = "Lorenz curve",
  highlight.below.curve = FALSE,
  highlight.below.curve.fillcolor = "gray",
  highlight.below.curve.alpha = 0.7,
  highlight.above.curve = FALSE,
  highlight.above.curve.fillcolor = "tomato",
  highlight.above.curve.alpha = 0.7,
  point.size = 2,
  ...
  ) {
  ggdata = object$data
  rcolors = colors()
  assertCharacter(xlab, len = 1L, any.missing = FALSE)
  assertCharacter(ylab, len = 1L, any.missing = FALSE)
  assertCharacter(main, len = 1L, any.missing = FALSE)
  assertFlag(highlight.below.curve, na.ok = FALSE)
  assertNumeric(highlight.below.curve.alpha, len = 1L, lower = 0L, upper = 1L, any.missing = FALSE)
  assertChoice(highlight.below.curve.fillcolor, choices = rcolors)
  assertFlag(highlight.above.curve, na.ok = FALSE)
  assertNumeric(highlight.above.curve.alpha, len = 1L, lower = 0L, upper = 1L, any.missing = FALSE)
  assertChoice(highlight.above.curve.fillcolor, choices = rcolors)
  assertNumeric(point.size, len = 1L, lower = 1L, any.missing = FALSE)

  pl = ggplot()
  if (highlight.below.curve) {
    ggpolygon = getPolygonBelowLorenzCurve(ggdata)
    pl = pl + geom_polygon(data = ggpolygon,
      mapping = aes_string(x = "x", y = "y"),
      alpha = highlight.below.curve.alpha,
      fill = highlight.below.curve.fillcolor)
  }
  if (highlight.above.curve) {
    pl = pl + geom_polygon(data = ggdata,
      mapping = aes_string(x = "x", y = "y"),
      alpha = highlight.above.curve.alpha,
      fill = highlight.above.curve.fillcolor)
  }
  pl = pl + geom_line(data = ggdata, aes_string(x = "x", y = "y"))
  pl = pl + geom_point(data = ggdata, aes_string(x = "x", y = "y"), size = point.size)
  pl = pl + xlab(xlab) + ylab(ylab)
  pl = pl + geom_abline(slope = 1, linetype = "dashed")
  pl = pl + ggtitle(main)
  return(pl)
}

getPolygonBelowLorenzCurve = function(d) {
  ggpolygon = data.frame(x = c(d$x, rev(d$x[-1])), y = c(rep(0, nrow(d)), rev(d$y[-1])))
  return(ggpolygon)
}

getLorenzCurveDataPoints = function(x) {
  n = length(x)
  xs = seq(n) / n

  cumsum_x = cumsum(sort(x))
  sum_x = cumsum_x[n]
  ys = cumsum_x / sum_x

  ggdata = data.frame(x = c(0,xs), y = c(0,ys))
  return(ggdata)
}
