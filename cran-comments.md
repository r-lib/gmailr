The vignettes and index are now being properly built, and the referenced
message is gone from R CMD check.  I apologize for overlooking this
on the previous submission.

Thanks,

Jim
> Please do check as per the policies.  You missed
> 
> Package has a VignetteBuilder field but no prebuilt vignette index.
> 
> Had you packed with R CMD build and R-devel (or even current R, I believe) this would have been created.
> 
> > Uwe,
> > 
> > I removed the final period from the title and the NEWS.md file.  Let me know
> > there are any other changes needed.
> > 
> > Thanks for your time,
> > 
> > Jim
> > > Thank,
> > > 
> > > no final dot, please.
> > > 
> > > 
> > > We also see:
> > > 
> > > * checking top-level files ... NOTE
> > > Non-standard file/directory found at top level:
> > >   'NEWS.md'
> > > 
> > > Please fix.
> > > 
> > > Best,
> > > Uwe Ligges
> > > > This release adds additional functionality to the package, and fixes some
> > > > overlooked bugs in the initial release.
> > > > 
> > > > I have ran cran check on my local OSX install and win builder and did generate any any NOTEs of interest.
> > > > 
> > > > Regards,
> > > > 
> > > > Jim Hester

