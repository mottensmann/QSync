#' Handling of duplicates
#'
#' @description
#' Identifies duplicated entries based on the uuid attribute and only returns the most recent entry, selected by the MTIME attribute
#'
#' @param db data frame
#' @param uuid string denoting the attribute used as universal-unique-identifier. Defaults to 'uuid'
#' @param MTIME string denoting the attribute used as universal-unique-identifier. Defaults to 'MTIME'
#' @examples
#' ## code example dataset
#' (db <- data.frame(uuid = LETTERS[1:10], MTIME = Sys.time()))
#' ## duplicate last entry db <- rbind(db,db[10,])
#' ## modify the time stamp by adding 1hour
#' db[11, "MTIME"] <- db[11, "MTIME"] + 60*60
#' db
#' ## Handle duplicate using the db_unique function
#' (db <- db_unique(db))
#'
#' @export
#'
db_unique <- function(db, uuid = 'uuid', MTIME = 'MTIME') {

  if (!uuid %in% names(db)) stop(paste('attribute', uuid, 'not found'))
  if (!MTIME %in% names(db)) stop(paste('attribute', MTIME, 'not found'))

  ## Check for duplicated uuid
  if (any(duplicated(db[[uuid]]))) {
    ## select duplicated uuid if present
    uuids <- unique(db[[uuid]][duplicated(db[[uuid]])])
    ## code dummy var
    DumyVarToDelete <- NULL
    db[["DumyVarToDelete"]] <- 1:nrow(db)
    ## Clean duplicates
    if (interactive()) {
      if (length(uuids) > 1 ) {
        cat(length(uuids), "duplicated entries detected\n")
      } else {
        cat(length(uuids), "duplicated entry detected\n")
      }

      cat("Clean records ... \n")
      indices <- pbapply::pbsapply(1:length(uuids), function(i) {
        ## select data ...
        dbx <- db[db[[uuid]] %in% uuids[i],]
        ## sort by mtime
        dbx <- dbx[order(dbx[[MTIME]], decreasing = T),]
        ## return row to delete
        return(dbx[["DumyVarToDelete"]][2:nrow(dbx)])
      })
      cat("... done \n")

    } else {
      indices <- sapply(1:length(uuids), function(i) {
        ## select data ...
        dbx <- db[db[[uuid]] %in% uuids[i],]
        ## sort by mtime
        dbx <- dbx[order(dbx[[MTIME]], decreasing = T),]
        ## return row to delete
        return(dbx[["DumyVarToDelete"]][2:nrow(dbx)])
      })
    }
    db <- db[-unlist(indices),]
    db <- subset(db, select = -(DumyVarToDelete))
  }
  return(db)
}
