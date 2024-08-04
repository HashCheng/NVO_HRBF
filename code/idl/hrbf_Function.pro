function getFxyz,p,x,c,cn
	n=(size(c))[2]
	sz=size(p)
	if sz[0] eq 1 then begin
		mt=1
		nn=1
	endif else if sz[0] eq 2 then begin
		mt=sz[2]
		nn=1
	endif else if sz[0] eq 3 then begin
		mt=sz[2]
		nn=sz[3]
	endif
	np=(sz[0] eq 1)?1:sz[2]

	f=dblarr(mt,nn)
	for j=0L,nn-1 do $
	for i=0L,mt-1 do begin
		dist=sqrt((p[0,i,j]-c[0,*])^2+(p[1,i,j]-c[1,*])^2+(p[2,i,j]-c[2,*])^2)
		ddx=p[0,i,j]-c[0,*]
		ddy=p[1,i,j]-c[1,*]
		ddz=p[2,i,j]-c[2,*]
		ff=0
		for k=0,cn-1 do begin
			ff=ff+x[4*k]*dist[k]^3-3*dist[k]*(x[4*k+1]*ddx[k]+x[4*k+2]*ddy[k]+x[4*k+3]*ddz[k])
		endfor
		f[i,j]=ff
	endfor
	return,f
end

pro hrbf_Function

	n=1071
	openr,fp,'F:\20230907\IDL1020\PP.txt',/get_lun
	c=dblarr(3,n);读取样本点
	readf,fp,c
	free_lun,fp
	openr,fp,'F:\20230907\IDL1020\HH.txt',/get_lun
	y=dblarr(3,n);
	readf,fp,y
	free_lun,fp

	h=dblarr(4*n)
	q=dblarr(4*n,4*n)

	h[0:n-1]=0
	h[n:2*n-1]=y[0,*]
	h[2*n:3*n-1]=y[1,*]
	h[3*n:4*n-1]=y[2,*]

	for i=0,n-1 do $
	for j=0,n-1 do begin
		if i ne j then begin
		t=sqrt(total((c[*,i]-c[*,j])^2))

		q[4*j,i]=t^3
		q[4*j+1,i]=-3*t*(c(0,i)-c(0,j))
		q[4*j+2,i]=-3*t*(c(1,i)-c(1,j))
		q[4*j+3,i]=-3*t*(c(2,i)-c(2,j))
		q[4*j,n+i]=3*t*(c(0,i)-c(0,j))
		q[4*j+1,n+i]=-3*(t+(c(0,i)-c(0,j))^2/t)
		q[4*j+2,n+i]=-3*(c[0,i]-c[0,j])*(c[1,i]-c[1,j])/t
		q[4*j+3,n+i]=-3*(c[0,i]-c[0,j])*(c[2,i]-c[2,j])/t

		q[4*j,2*n+i]=3*t*(c(1,i)-c(1,j))
		q[4*j+1,2*n+i]=-3*(c[0,i]-c[0,j])*(c[1,i]-c[1,j])/t
		q[4*j+2,2*n+i]=-3*(t+(c(1,i)-c(1,j))^2/t)
		q[4*j+3,2*n+i]=-3*(c[1,i]-c[1,j])*(c[2,i]-c[2,j])/t

		q[4*j,3*n+i]=3*t*(c(2,i)-c(2,j))
		q[4*j+1,3*n+i]=-3*(c[0,i]-c[0,j])*(c[2,i]-c[2,j])/t
		q[4*j+2,3*n+i]=-3*(c[1,i]-c[1,j])*(c[2,i]-c[2,j])/t
		q[4*j+3,3*n+i]=-3*(t+(c(2,i)-c(2,j))^2/t)
		endif else if i eq j then begin
		
		q[4*j,i]=0
		q[4*j+1,i]=0
		q[4*j+2,i]=0
		q[4*j+3,i]=0

		q[4*j,n+i]=0
		q[4*j+1,n+i]=0
		q[4*j+2,n+i]=0
		q[4*j+3,n+i]=0

		q[4*j,2*n+i]=0
		q[4*j+1,2*n+i]=0
		q[4*j+2,2*n+i]=0
		q[4*j+3,2*n+i]=0

		q[4*j,3*n+i]=0
		q[4*j+1,3*n+i]=0
		q[4*j+2,3*n+i]=0
		q[4*j+3,3*n+i]=0
		endif
	endfor
	qq=q
	LUDC,QQ,INDEX
	x=LUSOL(qq,INDEX,H)

	x2=max(c[0,*],min=x1)
	y2=max(c[1,*],min=y1)
	z2=max(c[2,*],min=z1)
	x1=x1-50
	x2=x2+50
	y1=y1-30
	y2=y2+30
	z1=z1-20
	z2=z2+20

	mt=193L
	nn=131L
	nz=211L
	dx=(x2-x1)/(mt-1)
	dy=(y2-y1)/(nn-1)
	dz=(z2-z1)/(nz-1)
	q=dblarr(3,mt,nn,nz)
	for k=0,nz-1 do $
	for j=0,nn-1 do begin
		q[0,*,j,k]=x1+indgen(mt)*dx
		q[1,*,j,k]=y1+j*dy
		q[2,*,j,k]=z1+k*dz
	endfor
	q=reform(q,3,mt*nn*nz)

	f=getFxyz(q,x,c,n)
	f=reform(f,mt,nn,nz)

	val=0.

	SHADE_VOLUME, f, val, p, ip, LOW=0
	p[0,*]=x1+p[0,*]*(x2-x1)/(mt-1)
	p[1,*]=y1+p[1,*]*(y2-y1)/(nn-1)
	p[2,*]=z1+p[2,*]*(z2-z1)/(nz-1)


	obj=obj_new('IDLGRPOLYGON',data=P,polygons=ip,style=2,SHADING=1,color=[0,0,255])
	save,obj,filename='F:\test.obj'

end